child @current_user do
	attributes :id
end

child @tasks do
	attributes :id, :name, :description, :user_id, :deadline, :completed
end

child @error => :error do
	attributes :message
end