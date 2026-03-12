class SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, only: %i[new create]
end
