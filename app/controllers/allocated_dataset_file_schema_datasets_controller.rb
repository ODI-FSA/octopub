class AllocatedDatasetFileSchemaDatasetsController < ApplicationController
  include FileHandlingForDatasets

  before_action :check_signed_in?
  before_action :check_permissions
  before_action :get_multipart, only: :create
  before_action :clear_files, only: :create
  before_action :process_files, only: :create
  before_action :check_mandatory_fields, only: :create
  before_action :set_direct_post, only: :new

  def new
    logger.info "AllocatedDatasetFileSchemaDatasetsController: In new"
    @dataset = Dataset.new
    @dataset_file_schema_id = params[:dataset_file_schema_id]
    @dataset_file_schema = DatasetFileSchema.find(@dataset_file_schema_id)
  end

  def create
    logger.info "AllocatedDatasetFileSchemaDatasetsController: In create"
    dataset_params_hash = dataset_params.to_h
    dataset_params_hash[:publishing_method] = :local_private
    dataset_params_hash[:publisher_name] = current_user.name
    dataset_params_hash[:owner] = current_user.name

    files_array = get_files_as_array_for_serialisation

    CreateDataset.perform_async(dataset_params_hash, files_array, current_user.id, channel_id: params[:channel_id])

    if params[:async]
      logger.info "DatasetsController: In create with params aysnc"
      head :accepted
    else
      redirect_to created_datasets_path
    end
  end

  private

  def check_mandatory_fields
    logger.info "DatasetsController: In check_mandatory_fields"
    check_files
    render 'new' unless flash.empty?
  end

  def set_direct_post
    @s3_direct_post = FileStorageService.private_presigned_post
  end

  def check_permissions
   # render_403 unless current_user.all_dataset_ids.include?(params[:id].to_i)
  end
end
