class SalesforceNewStudentWorker
  include Sidekiq::Worker

  def perform(id)
    SalesForce.GetStudent(id)
  end
end
