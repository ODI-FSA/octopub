# == Schema Information
#
# Table name: schema_categories
#
#  id          :integer          not null, primary key
#  name        :text
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class SchemaCategory < ApplicationRecord
  has_and_belongs_to_many :dataset_file_schemas, join_table: :schema_categories_dataset_file_schemas
  validates_presence_of :name
end
