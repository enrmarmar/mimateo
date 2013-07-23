class GoogleEvent < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

  before_save do
    if self.google_id
      self.google_api_destroy
    end
    self.google_id = google_api_insert.data.id
    true
  end

  before_destroy do  
    self.google_api_destroy
  end

  def google_api_insert
    event = {
      'summary' => self.task.name,
      'description' => self.task.description + '  <<MiMateo>>',
      'start' => {
        'date' => self.task.deadline
      },
      'end' => {
        'date' => self.task.deadline
      },
    }
    client = ClientBuilder.get_client(self.user)
    service = client.discovered_api('calendar', 'v3')
    result = client.execute(
      :api_method => service.events.insert,
      :parameters => {'calendarId' => 'primary'},
      :body => JSON.dump(event),
      :headers => {'Content-Type' => 'application/json'})
  end

  def google_api_destroy
    client = ClientBuilder.get_client self.user 
    service = client.discovered_api 'calendar', 'v3'
    result = client.execute(
      :api_method => service.events.delete,
      :parameters => {
        'calendarId' => 'primary',
        'eventId' => self.google_id})
  end


end