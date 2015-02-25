require 'spec_helper'
require 'wash_out/router'

describe WashOut::Router do
  it 'returns a 200 with empty soap action' do

    mock_controller do
      # nothing
    end

    env = {}
    env['REQUEST_METHOD'] = 'GET'
    env['rack.input'] = double 'basic-rack-input', {:string => ''}
    result = WashOut::Router.new('Api').call env

    expect(result[0]).to eq(200)
    #expect(result[1]['Content-Type']).to eq('text/xml')

    msg = result[2][0]
    expect(msg).to eq('OK')
  end

  describe "parse_soap_parameters" do
    before(:each) {
      @router = WashOut::Router.new('Api')
      allow(@router).to receive(:controller).and_return(double('controller', soap_config: WashOut::SoapConfig.new({ camelize_wsdl: false })))
    }
    let(:env){ {'rack.input' => double('basic-rack-input', {:string => @xml}) }}

    it "parses typical request" do
      @xml = "<foo>1</foo>"
      expect(@router.parse_soap_parameters(env)).to eq({:foo => "1"})
    end

    it "parses href requests" do
      @xml = <<-XML
        <root>
          <request>
            <entities href="#id1">
            </entities>
          </request>
          <entity id="id1">
            <foo><bar>1</bar></foo>
            <sub href="#id2" />
          </entity>
          <ololo id="id2">
            <foo>1</foo>
          </ololo>
        </root>
      XML
      expect(@router.parse_soap_parameters(env)).to eq({:root=>{
        :request=>{:entities=>{:foo=>{:bar=>"1"}, :sub=>{:foo=>"1", :@id=>"id2"}, :@id=>"id1"}},
        :entity=>{:foo=>{:bar=>"1"}, :sub=>{:foo=>"1", :@id=>"id2"}, :@id=>"id1"},
        :ololo=>{:foo=>"1", :@id=>"id2"}
      }})
    end

    it "parses href request with arrays" do
      @xml = <<-XML
        <root xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <request>
            <schedule_data href="#id1"/>
          </request>
          <schedule_data id="id1" xsi:type="schedule_data">
            <schedule href="#id2"/>
          </schedule_data>
          <soapenc:Array id="id2" soapenc:arrayType="sae[1]">
            <Item href="#id3"/>
          </soapenc:Array>
          <sae id="id3" xsi:type="sae">
            <fname xsi:type="xsd:string">Test</fname>
            <lname xsi:type="xsd:string">Test</lname>
          </sae>
        </root>
      XML
      expect(@router.parse_soap_parameters(env)).to eq({:root=>{
        :request=>{:schedule_data=>{:schedule=>[{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"}], :@id=>"id1", :"@xsi:type"=>"schedule_data"}},
        :schedule_data=>{:schedule=>[{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"}], :@id=>"id1", :"@xsi:type"=>"schedule_data"},
        :Array=>{:Item=>{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"}, :@id=>"id2", :"@soapenc:arrayType"=>"sae[1]"},
        :sae=>{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"},
        :"@xmlns:soapenc"=>"http://schemas.xmlsoap.org/soap/encoding/", :"@xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance"
      }})
    end

    it "parses href request with arrays" do
      @xml = <<-XML
        <root xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <request>
            <schedule_data href="#id1"/>
          </request>
          <schedule_data id="id1" xsi:type="schedule_data">
            <schedule href="#id2"/>
          </schedule_data>
          <soapenc:Array id="id2" soapenc:arrayType="sae[1]">
            <Item href="#id3"/>
            <Item href="#id4"/>
          </soapenc:Array>
          <sae id="id3" xsi:type="sae">
            <fname xsi:type="xsd:string">Test</fname>
            <lname xsi:type="xsd:string">Test</lname>
          </sae>
        <sae id="id4" xsi:type="sae">
            <fname xsi:type="xsd:string">Test</fname>
            <lname xsi:type="xsd:string">Test</lname>
          </sae>
        </root>
      XML
      expect(@router.parse_soap_parameters(env)).to eq({:root=>{
        :request=>{:schedule_data=>{:schedule=>[{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"}, {:fname=>"Test", :lname=>"Test", :@id=>"id4", :"@xsi:type"=>"sae"}], :@id=>"id1", :"@xsi:type"=>"schedule_data"}},
        :schedule_data=>{:schedule=>[{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"}, {:fname=>"Test", :lname=>"Test", :@id=>"id4", :"@xsi:type"=>"sae"}], :@id=>"id1", :"@xsi:type"=>"schedule_data"},
        :Array=>{:Item=>[{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"}, {:fname=>"Test", :lname=>"Test", :@id=>"id4", :"@xsi:type"=>"sae"}], :@id=>"id2", :"@soapenc:arrayType"=>"sae[1]"},
        :sae=>[{:fname=>"Test", :lname=>"Test", :@id=>"id3", :"@xsi:type"=>"sae"}, {:fname=>"Test", :lname=>"Test", :@id=>"id4", :"@xsi:type"=>"sae"}],
        :"@xmlns:soapenc"=>"http://schemas.xmlsoap.org/soap/encoding/", :"@xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance"
      }})
    end


  end

end
