class Expense < ApplicationRecord
  include HTTParty

  belongs_to :membership
  has_one :user, through: :membership
  has_one :group, through: :membership

  validates :amount, :vendor, presence: true

  GOOGLE_API = "https://vision.googleapis.com/v1/images:annotate?key=" + ENV["GOOGLE_API_KEY"]


  # json object rendering methods
  def json_data
    { id: self.id, membership_id: self.membership_id, amount: self.amount.round(2), paid_by: self.user.full_name, description: self.description, vendor: self.vendor, group_id: self.group.id }
  end

  def group_json_data
    { vendor: self.vendor, amount: self.amount.round(2), group_id: self.group.id, id: self.id }
  end

  def post_camera_api(img_64)
    @result = HTTParty.post(GOOGLE_API,
    :body => {"requests":[
                {
                  "image":{
                    "content": img_64
                  },
                  "features":[
                    {
                      "type":"TEXT_DETECTION",
                      "maxResults":1
                    }
                  ]
                }
              ]
            }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    # binding.pry
    # puts @result.response
  end

  def find_total_from_receipt(str)
  # for cash and change
  arr = str.scan(/\d+\.\d{2}/)
    if arr[-3].to_f + arr[-1].to_f == arr[-2].to_f && arr.length != 0
      arr[-3]
    elsif arr.length != 0
      arr.last
    else
      "no dollor amount found"
    end
  end
end
