# == Schema Information
#
# Table name: errors
#
#  id       :integer          not null, primary key
#  job_id   :string           not null
#  messages :json
#

class Error < ApplicationRecord
end
