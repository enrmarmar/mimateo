child @task do
  attributes :id, :name, :description, :user_id, :deadline, :completed, :errors
end

child @status => :status do
	attributes :error, :info
end