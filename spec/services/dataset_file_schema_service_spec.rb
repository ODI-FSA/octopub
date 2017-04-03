require 'rails_helper'

describe DatasetFileSchemaService do

  let(:user) { create(:user) }
  let(:infer_schema_filename) { @filename || 'schemas/infer-from/data_infer.csv' }
  let(:good_schema_file) { get_fixture_schema_file('good-schema.json') }
  let(:good_schema_file_as_json) { File.read(good_schema_file).strip }
  let(:good_schema_url) { url_with_stubbed_get_for(good_schema_file) }
  let(:schema_name) { Faker::Cat.name }
  let(:description) { Faker::Cat.name }

  before(:each) do
    @schema_service = DatasetFileSchemaService.new(schema_name, description, good_schema_url, user, user.name)
  end

  context "when a user is set" do

    before(:each) do
      @thing = @schema_service.create_dataset_file_schema
    end

    it "creates a new dataset file schema" do
      expect(@thing).to be_instance_of(DatasetFileSchema)
      expect(@thing.id).to_not be nil
      expect(@thing.user).to be user
    end

    it 'creates a new dataset and updates schema as json' do
      expect(@thing.schema).to eq good_schema_file_as_json
      expect(@thing.csv_on_the_web_schema).to be false
    end

    it 'allows retrieval of schemas from user' do
      expect(user.dataset_file_schemas).to include(@thing)
    end
  end

  context 'returns a parsed schema' do

    before(:each) do
      @thing = @schema_service.create_dataset_file_schema
    end

    it 'when requested' do
      parsed_schema = DatasetFileSchemaService.get_parsed_schema_from_csv_lint(good_schema_url)
      expect(parsed_schema).to be_instance_of Csvlint::Schema
    end
  end

  context 'with a csv on the web schema' do
    let(:csv_schema_file) { get_fixture_schema_file('csv-on-the-web-schema.json') }
    let(:csv_schema_file_as_json) { File.read(csv_schema_file).strip }
    let(:csv_schema_file_url) { url_with_stubbed_get_for(csv_schema_file) }

    before(:each) do
      @csv_schema_service = DatasetFileSchemaService.new(schema_name, description, csv_schema_file_url, user, user.name)
      @csv_thing = @csv_schema_service.create_dataset_file_schema
    end

    it 'creates a new dataset and updates as csv on the web if appropriate' do
      expect(JSON.parse @csv_thing.schema.squish).to eq JSON.parse csv_schema_file_as_json
      expect(@csv_thing.csv_on_the_web_schema).to be true
    end
  end
end
