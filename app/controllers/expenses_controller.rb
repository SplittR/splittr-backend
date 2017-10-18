class ExpensesController < ApplicationController

  def create
    puts params
    expense = Expense.new(expense_params)
    membership = Membership.find_by(user_id: params[:expense][:user_id], group_id: params[:expense][:group_id])
    expense.membership = membership
    if expense.save
      render json: expense
    else
      puts expense.errors.full_messages
      render json: {errors: expense.errors.full_messages}
    end
  end

  def show
    expense = Expense.find_by(id: params[:expense_id])
    if expense
      render json: expense.json_data
    else
      render json: {error: "Expense does not exist, please try again"}
    end
  end

  def destroy
    expense = Expense.find_by(id: params[:id])
    if expense.destroy
      render json: {message: "Delete successful"}
    else
      render json: {message: "Something went wrong"}
    end
  end

  def camera
    puts params.keys
    image = params[:data][:data]
    # puts image
    expense = Expense.new
    resp = expense.post_camera_api(image)
    text = resp["responses"][0]["fullTextAnnotation"]["text"]
    total = expense.find_total_from_receipt(text)
    puts total
    render json: { total: total }
  end

  private
  def expense_params
    params.require(:expense).permit(:amount, :vendor, :description, :membership_id)
  end
end
