# document action controller
class DocumentsController < ApplicationController
  before_action :authenticate_user

  def api_tokens
    # access_token = Auth0Client.get_token
    # render json: { access_token: access_token }, status: :created
    render json: { message: 'success' }
  end

  def index
    documents = fetch_documents
    render json: documents, status: :ok
  end

  def create
    document = Document.create
    filename = params[:document].original_filename.gsub(/[\/]/, '_')
    document.name = params[:name]
    document.s3_url = "https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/Uploads/#{filename}"
    if document.save
      S3UploaderWorker.perform_async(document.id, filename, params[:document].path)
      render json: document, status: :created, location: document
    else
      render json: document.errors, status: :unprocessable_entity
    end
  end

  def show
    document = Document.find_by(id: params[:id])
    return render json: { message: 'Document not found.' }, status: :ok if document.nil?

    render json: document
  end

  def destroy
    document = Document.find_by(id: params[:id])
    return render json: { message: 'Document not found.' }, status: :ok if document.nil?

    document.destroy
    render json: { message: 'Document deleted successfully' }, status: :ok
  end

  private

  def authenticate_user
    # Authenticate the user using the access token from headers
    # Ensure valid access token to access this endpoint
  end

  def fetch_documents
    Document.all
  end

  def document_params
    params.fetch(:document, {})
  end
end
