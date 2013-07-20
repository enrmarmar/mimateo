child @current_user do
	attributes :id
end

child @tasks do
	attributes :id, :name, :description, :user_id, :deadline, :completed
end