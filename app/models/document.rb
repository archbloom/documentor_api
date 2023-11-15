# document has name, s3_url and will uploaded to s3
class Document < ApplicationRecord
  before_destroy :remove_from_s3

  private

  def remove_from_s3
    byebug
    return if s3_url.blank?

    s3 = Aws::S3::Resource.new
    obj = s3.bucket(ENV['S3_BUCKET']).object(s3_url.split('/').last)
    obj.delete
  end
end
