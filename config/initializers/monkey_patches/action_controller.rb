if ActionController.const_defined? 'ForbiddenError'
  raise 'ActionController::ForbiddenError already defined'
end

module ActionController
  class ForbiddenError < ActionControllerError; end
end # module HTTPStatusCodes
