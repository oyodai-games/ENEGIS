# frozen_string_literal: true

# ApplicationRecord is the base class for all models in the application.
# It provides shared functionality and acts as the superclass for all ActiveRecord models.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
