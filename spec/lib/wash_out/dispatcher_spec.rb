#encoding:utf-8

require 'spec_helper'

describe WashOut::Dispatcher do

  class Dispatcher < ApplicationController
    soap_service

    def params
      @_params
    end
  end

  it "finds nested hashes" do
    WashOut::Dispatcher.deep_select(:foo => 1){|k,v| k == :foo}.should == [1]
    WashOut::Dispatcher.deep_select({:foo => {:foo => 1}}){|k,v| k == :foo}.should == [{:foo => 1}, 1]
  end

  it "replaces nested hashed" do
    WashOut::Dispatcher.deep_replace_href({:foo => {:@href => 1}}, {1 => 2}).should == {:foo => 2}
    WashOut::Dispatcher.deep_replace_href({:bar => {:foo => {:@href => 1}}}, {1 => 2}).should == {:bar => {:foo => 2}}
  end

  it "processes referenced array objects" do
    test_arr = {:Envelope=>{:Body=>{
      :ScheduleSubmit => {:schedule_data=>{:@href=>"#id1"}},
      :schedule_data => { :schedule=>{:@href=>"#id2"}, :@id=>"id1"},
      :Array=>{:Item=>{:@href=>"#id3"},:@id=>"id2",:"@soapenc:arrayType"=>"tns:soap_aircraft_event[1]"},
      :soap_aircraft_event=>{:fname=>"Test",:lname=>"User",:@id=>"id3"}}}
    }
    expect(WashOut::Dispatcher.process_referenced_arrays_objects(test_arr)).to eq({:Envelope=>{:Body=>{
      :ScheduleSubmit=>{:schedule_data=>{:@href=>"#id1"}},
      :schedule_data=>{:schedule=>[{:@href=>"#id3"}], :@id=>"id1"},
      :Array=>{:Item=>{:@href=>"#id3"}, :@id=>"id2", :"@soapenc:arrayType"=>"tns:soap_aircraft_event[1]"},
      :soap_aircraft_event=>{:fname=>"Test", :lname=>"User", :@id=>"id3"}}}})
  end




  describe "#_map_soap_parameters" do
    let(:dispatcher) { Dispatcher.new }
    let(:soap_config) { WashOut::SoapConfig.new(camelize_wsdl: false) }

    before do
      allow(dispatcher).to receive(:action_spec).and_return(in: WashOut::Param.parse_def(soap_config, {:empty => :string } ))
      allow(dispatcher).to receive(:xml_data).and_return(:empty => { :"@xsi:type" => "xsd:string" })
    end

    it "should handle empty strings that have been parsed wrong by nori" do
      dispatcher._map_soap_parameters
      expect(dispatcher.params).to eq('empty' => nil)
    end
  end

  describe "#_load_params" do
    let(:dispatcher) { Dispatcher.new }
    let(:soap_config) { WashOut::SoapConfig.new({ camelize_wsdl: false }) }
    it "should load params for an array" do
      spec = WashOut::Param.parse_def(soap_config, {:my_array => [:integer] } )
      xml_data = {:my_array => [1, 2, 3]}
      dispatcher._load_params(spec, xml_data).should == {"my_array" => [1, 2, 3]}
    end

    it "should load params for an empty array" do
      spec = WashOut::Param.parse_def(soap_config, {:my_array => [:integer] } )
      xml_data = {}
      dispatcher._load_params(spec, xml_data).should == {}
    end

    it "should load params for a nested array" do
      spec = WashOut::Param.parse_def(soap_config, {:nested => {:my_array => [:integer]}} )
      xml_data = {:nested => {:my_array => [1, 2, 3]}}
      dispatcher._load_params(spec, xml_data).should == {"nested" => {"my_array" => [1, 2, 3]}}
    end

    it "should load params for an empty nested array" do
      spec = WashOut::Param.parse_def(soap_config, {:nested => {:empty => [:integer] }} )
      xml_data = {:nested => nil}
      dispatcher._load_params(spec, xml_data).should == {"nested" => {}}
    end

  end

end
