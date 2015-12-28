module ServicesHelper
    def service_connected? (service)
        current_user.services.find_by(name: service).nil?
    end
end
