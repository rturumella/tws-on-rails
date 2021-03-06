require 'spec_helper.rb'

describe UpdateTeaTime do
  let(:params) { {location: 'Somewhere Else'} }
  let(:new_host_params) { {user_id: create(:user, :host).id } }
  let(:tt) { create(:tea_time, :attended) }

  describe '#call' do
    it 'should update the tea time' do
      UpdateTeaTime.call(tt, params)
      expect(tt.location).to eq params[:location]
      expect(tt.persisted?).to eq true
    end

    it 'should change the host and fire a notification' do
      UpdateTeaTime.call(tt, new_host_params)
      expect(TeaTime.find(tt.id).host).to eq User.find(new_host_params[:user_id])
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it 'should not fire a notification for same host' do
      UpdateTeaTime.call(tt, params)
      expect(tt.host).to eq User.find(tt.host.id)
      expect(ActionMailer::Base.deliveries.count).to eq 0
    end
  end

  describe '#host_changed?' do
    it 'should return true for a different host' do
      expect(UpdateTeaTime.host_changed?(tt, new_host_params)).to eq true
    end

    it 'should return true even for a string ID' do
      new_host_params[:user_id] = new_host_params[:user_id].to_s
      expect(new_host_params[:user_id].class).to eq String
      expect(UpdateTeaTime.host_changed?(tt, new_host_params)).to eq true
    end
  end
  
end
