child @task do
  attributes :id, :name, :description, :user_id, :deadline, :completed, :errors
end

child @error => :error do
	attributes :message
end