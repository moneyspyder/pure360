require 'spec_helper'

describe Pure360 do
  let(:params) do
    { endpoint:              "https://news.test.com/lists",
      list:                  "ActiveData_2014-04-14",
      account:               "Client",
      full_email_validation: false,
      double_opt_in:         false }
  end

  context "#new" do
    it 'Parses an HTTPS endpoint' do
      p360 = Pure360::Client.new(params)

      p360.instance_variable_get(:@endpoint).should be_kind_of(URI::HTTPS)
    end

    it 'Parses an HTTP endpoint' do
      params[:endpoint] = "http://test.com"
      p360 = Pure360::Client.new(params)

      p360.instance_variable_get(:@endpoint).should be_kind_of(URI::HTTP)
    end

    it 'Creates a new object' do
      p360 = Pure360::Client.new(params)

      p360.instance_variable_get(:@list).should eq(params[:list])
      p360.instance_variable_get(:@account).should eq(params[:account])
      p360.instance_variable_get(:@full_email_validation).should eq(params[:full_email_validation])
      p360.instance_variable_get(:@double_opt_in).should eq( params[:double_opt_in])
    end
  end

  context "#subscribe" do
    context 'Successful subscribe' do
      let(:subscriber_params) {
        { :email => 'test@test.com' } }

      let(:p360) { Pure360::Client.new(params) }
      let(:parsed_endpoint) { URI.parse(params[:endpoint]) }

      before do
        Net::HTTP = double().as_null_object
      end

      it 'sends a subscribe request to the endpoint' do
        Net::HTTP.should_receive(:post_form).with(parsed_endpoint, [subscriber_params])

        p360.subscribe(subscriber_params)
      end

      it 'sends any custom customer params specified to the endpoint' do
        custom_value = { custom_value: "Some custom value" }
        subscriber_params.merge!(custom_value)

        Net::HTTP.should_receive(:post_form).with(parsed_endpoint, [subscriber_params])

        p360.subscribe(subscriber_params)
      end
    end

    context 'Unsuccessful subscribe' do
      it 'fails if an email is not present in the subscriber params' do
        subscriber_params = {}
        expect { Pure360::Client.new(params).subscribe(subscriber_params) }.to raise_error
      end

      it 'fails if an email is present in the subscriber params but blank' do
        subscriber_params = { email: "" }
        expect { Pure360::Client.new(params).subscribe(subscriber_params) }.to raise_error
      end

      it 'fails if an email is present in the subscriber params but blank' do
        subscriber_params = { email: nil }
        expect { Pure360::Client.new(params).subscribe(subscriber_params) }.to raise_error
      end
    end
  end
end
