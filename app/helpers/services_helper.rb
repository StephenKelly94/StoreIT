module ServicesHelper
    def service_connected? (service)
        current_user.services.find_by(name: service).nil?
    end

    def how_many_connected
        services=0
        services+=1 unless service_connected?('Dropbox')
        services+=1 unless service_connected?('Onedrive')
        services+=1 unless service_connected?('Googledrive')
        if services == 2
            return 'col-md-4 col-md-offset-1 dropzone'
        elsif services == 1
            return 'col-md-4 col-md-offset-4 dropzone'
        else
            return 'col-md-4 dropzone'
        end
    end
end
