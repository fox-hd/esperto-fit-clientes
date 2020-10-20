require 'rails_helper'

RSpec.describe Client, type: :model do
  context 'respond_to' do
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:cpf) }
    it { is_expected.to respond_to(:partner?) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:cpf) }
    it { is_expected.to validate_presence_of(:email) }
    it 'Uniqueness CPF' do
      create(:client, cpf: '08858754948')
      client = build(:client, cpf: '0885875-4948')
      client.valid?

      expect(client).to_not be_valid
      expect(client.errors[:cpf]).to include('já está em uso')
    end
  end

  context 'associations' do
    it { is_expected.to have_many(:order_appointments).dependent(:destroy) }
  end

  context 'verify partnership' do
    it '#partner? => true' do
      client = create(:client, cpf: '478.145.318-02')
      allow(client).to receive(:partner?).and_return(true)

      expect(client.partner?).to be_truthy
    end

    it '#is_partner? => true' do
      client = create(:client, email: 'client@partner_company.com', cpf: '478.145.318-02')

      expect(client.partner?).to be_truthy
    end

    it '#is_partner? => false' do
      client = create(:client, cpf: '478.145.318-02')
      allow(client).to receive(:partner?).and_return(false)

      expect(client.partner?).to be_falsey
    end
  end

  context '#cpf_banned?' do
    it 'response is true from API' do
      allow_any_instance_of(Client).to receive(:cpf_banned?).and_call_original
      client = build(:client, status: nil)
      faraday_response = double('cpf_ban', status: 200, body: 'true')
      allow(Faraday).to receive(:get).with("http://subsidiaries/api/v1/banned_user/#{CPF.new(client.cpf).stripped}")
                                     .and_return(faraday_response)

      response = client.cpf_banned?

      expect(response).to eq true
      expect(client.valid?).to eq true
    end

    it 'response is false from API' do
      allow_any_instance_of(Client).to receive(:cpf_banned?).and_call_original
      client = build(:client, status: nil)
      faraday_response = double('cpf_ban', status: 200, body: 'false')
      allow(Faraday).to receive(:get).with("http://subsidiaries/api/v1/banned_user/#{CPF.new(client.cpf).stripped}")
                                     .and_return(faraday_response)

      response = client.cpf_banned?

      expect(response).to eq false
      expect(client.valid?).to eq true
    end

    it 'error on API' do
      allow_any_instance_of(Client).to receive(:cpf_banned?).and_call_original
      client = build(:client, status: nil)
      faraday_response = double('cpf_ban', status: 500)
      allow(Faraday).to receive(:get).with("http://subsidiaries/api/v1/banned_user/#{CPF.new(client.cpf).stripped}")
                                     .and_return(faraday_response)

      response = client.cpf_banned?

      expect(response).to eq nil
      expect(client.valid?).to eq false
    end
  end
end
