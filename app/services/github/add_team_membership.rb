class AddTeamMembership < Eldr::Action
  attr_accessor :team_id, :username, :membership

  def initialize(team_id: ENV['GITHUB_TEAM_ID'], username:)
    @team_id  = team_id
    @username = username
    @client   = Octokit::Client.new access_token: ENV['GITHUB_ACCESS_TOKEN']
  end

  def call(_env)
    begin
      @membership = @client.add_team_membership team_id, username
      @membership
    rescue
      errors.add(:base, 'Could not give you read permisions to GitHub repos. Please contact k@2052.me')
    end
  end
end
