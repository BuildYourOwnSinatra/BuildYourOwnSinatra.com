describe AddTeamMembership do
  describe '.new' do
    it 'returns a new instance' do
      add_team_membership = AddTeamMembership.new(team_id: '946194', username: 'api-padawan')
      expect(add_team_membership).to be_instance_of AddTeamMembership
    end
  end

  describe '#call' do
    context 'when valid' do
      before do
        stub_request(:put, "https://api.github.com/teams/946194/memberships/api-padawan").to_return(
          :status => 200,
          :headers => {
            "Content-Type" => "application/json; charset=utf-8"
          },
          :body =>  '{
            "url": "https://api.github.com/teams/946194/memberships/api-padawan",
            "state": "pending"
          }'
        )
      end

      subject(:add_team_membership) do
        AddTeamMembership.new(team_id: '946194', username: 'api-padawan')
      end

      it 'has no errors' do
        add_team_membership.call({})
        expect(add_team_membership.errors.messages).to be_empty
      end

      it 'returns a pending membership' do
        membership = add_team_membership.call({})
        expect(membership.state).to eq('pending')
      end
    end

    context 'when invalid' do
      before do
        stub_request(:put, "https://api.github.com/teams/946194/memberships/api-padawan").to_return(
        :status => 422,
        :headers => {
          "Content-Type" => "application/json; charset=utf-8"
        },
        :body =>  '
          {
            "message": "Cannot add an organization as a member.",
            "errors": [
              {
                "code": "org",
                "field": "user",
                "resource": "TeamMember"
              }
            ]
          }')
      end

      subject(:add_team_membership) do
        AddTeamMembership.new(team_id: '946194', username: 'api-padawan')
      end

      it 'has errors' do
        add_team_membership.call({})
        expect(add_team_membership.errors.messages).to_not be_empty
        expect(add_team_membership.errors.messages[:base].first).to eq('Could not give you read permisions to GitHub repos. Please contact k@2052.me')
      end
    end
  end
end
