#!/usr/bin/env ruby
# crontab -e
# 20 * * * * ruby newegg.rb        ---cronjob
require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'rubygems'
require 'pony'
require 'net/smtp'

class Monitor
	attr_accessor :email
	attr_accessor :resolution
	attr_accessor :price
	attr_accessor :size
	attr_accessor :resolutionC
	attr_accessor :priceC
	attr_accessor :sizeC
	def initialize(resolution="1680x1050",price = "100.00", size = "22", resolutionC=">=", priceC="<=", sizeC=">=")
	end
	
	def setVar(param,value,constraint="==")
		instance_variable_set("@"+param, value)
		instance_variable_set("@"+param+"C", constraint)
	end
end

class NeweggScraper
    num=0
    attr_accessor :url
    def initialize(type)
	if type=="monitor"
		@url="/Product/ProductList.aspx?Submit=ENE&N=100007617%204809&IsNodeId=1&bop=And&Order=PRICE&PageSize=100"
		@mon=Monitor.new()
	end
    end
    def setVars(type,param,value,contraint)
	if type=="monitor"
    		@mon.setVar(param,value,contraint)
	end
    end


    def scan(param)
	if param=="monitor"
		#pageO=Net::HTTP.get 'www.newegg.com', @url


def getItemNum(html)
tar="#{html}"
regex = Regexp.new(/Item #: <\/b>(\w+)<\/li>/)
matchdata = regex.match(tar)
if matchdata
	return matchdata[1]
else
	puts "NO MATCH"
end
end

def getPrice(html)
tar="#{html}"
regex = Regexp.new(/<li class="priceFinal">\s<span class="label">Now:\s<\/span>\$<strong>(\d+)<\/strong><sup>(\.\d+)/)
matchdata = regex.match(tar)
if matchdata
	return matchdata[1]+matchdata[2]
else
	puts "NO MATCH"
end
end

def getinfo(html, type)
new=Nokogiri::HTML(Net::HTTP.get 'www.newegg.com', '/Product/Product.aspx?Item='+getItemNum(html))
new.xpath('//div[@id="Specs"]//dl').each do |item|
	tar=/#{type}/
	if type=="Recommended Resolution"
		tarr=/\d+\sx\s\d+/
	end
	if type=="Screen Size"
		tarr=/\d+\.?\d?/
	end
	
	regex = Regexp.new(/#{tar}\s+(#{tarr})/)
	matchdata = regex.match(item)
	if matchdata
		#puts item
		return matchdata[1]
	else
		#puts "NO MATCH"
	end
end
end



@url="/Product/ProductList.aspx?Submit=ENE&N=100007617%204809&IsNodeId=1&bop=And&Order=PRICE&PageSize=100"
base=Nokogiri::HTML(Net::HTTP.get 'www.newegg.com', @url)

base.xpath('//div[@class="itemCell"]').each do |item|
	rez=getinfo(item,"Recommended Resolution")
	size=getinfo(item,"Screen Size")
	price=getPrice(item)
	numm=getItemNum(item)

cnt=0
if @mon.resolutionC==">=\n"
	if @mon.resolution[0..3]<=rez[0..3]
	cnt+=1	
	end
end
if @mon.resolutionC=="==\n"
	if @mon.resolution==rez
	cnt+=1	
	end
end
if @mon.resolutionC=="<=\n"
	if @mon.resolution>=rez
	cnt+=1	
	end
end
if @mon.priceC==">=\n"
	if Float(@mon.price)<=Float(price)
	cnt+=1	
	end
end
if @mon.priceC=="==\n"
	if Float(@mon.price)==Float(price)
	cnt+=1	
	end
end
if @mon.priceC=="<=\n"
	if Float(@mon.price)>=Float(price)
	cnt+=1	
	end
end
if @mon.sizeC==">=\n"
	if @mon.size<=size
	cnt+=1	
	end
end
if @mon.sizeC=="==\n"
	if @mon.size==size
	cnt+=1	
	end
end
if @mon.sizeC=="<=\n"
	if @mon.size>=size
	cnt+=1	
	end
end
if cnt==3
puts @mon.email

#Pony.mail(:to => @mon.email, :via => :smtp, :via_options => {
#:address => 'smtp.gmail.com',
#:port => '587',
#:enable_starttls_auto => true,
#:user_name => 'id_gmail@gmail.com',
#:password => 'parola_gmail',
#:authentication => :plain, # :plain, :login, :cram_md5, no auth by default
#:domain => "HELO", # don't know exactly what should be here
#
#},
#:subject => 'newegg bot has found something', :body => 'http://www.newegg.com/Product/Product.aspx?Item='+numm)

end
#puts cnt
end	
		#puts @mon.email
		puts "done"
		
	end
    end
	
end
if __FILE__ == $0
    begin
    @file=File.new("search.txt","r")
    rescue
        @file=File.new("search.txt","w+")
    end
end
@lines = IO.readlines("search.txt")
@data=[]
set=[]
on=false
@lines.each do |line|
	if on && line!="end\n"
	set.push(line.split(/:/))
	end
        if line=="monitor\n" && !on
		on=true
	end
	if line=="end\n" && on
	@data.push(set)
	set=[]
	on=false
	end
	
end

#puts "#{@data[0][0][0]}"

@data.each do |monitor|
nes = NeweggScraper.new("monitor")
#monitor[0].each do |var|
#puts monitor[1][0]
x=0
while x<monitor.length
	nes.setVars("monitor",monitor[x][0],monitor[x][1],monitor[x][2])
	x+=1
end
#end
#x = 2
#while x < monitor[1]+2
    #nes.setVars(monitor[0],monitor[x][0],monitor[x][1],monitor[x][2])
    #x = x + 1
#end
nes.scan("monitor")
end
