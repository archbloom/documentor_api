# s3 uploader worker
class S3UploaderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(doc_id, filename, filepath)
    s3 = Aws::S3::Resource.new
    s3.bucket(ENV['S3_BUCKET']).object("Uploads/#{filename}").upload_file(filepath)
  rescue => e
    doc = Document.find_by(id: doc_id)
    doc.s3_url = ''
    doc.name = filename
    doc.save
  end
end
