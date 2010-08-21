require 'RMagick'
class Yacht < ActiveRecord::Base

  cattr_accessor :current_yacht
  belongs_to :category
  belongs_to :type
  belongs_to :hull_type
  belongs_to :condition
  belongs_to :engine_type
  belongs_to :propeller_type
  belongs_to :manufacturer
  belongs_to :engine_maker
  belongs_to :engine_drive
  belongs_to :propeller_material
  belongs_to :broker
  has_many :galleries
  has_many :additionaldetails
  has_and_belongs_to_many :keysellingfeatures
  has_many :saved_yatches
  has_many :attachments
  has_one :carousel_list
  has_one :key_inventory
  
  named_scope :yachtname, lambda { |*args| (args.size > 0 and !args.first.blank?)?({:conditions => ["documentation_no like :searchname or hin like :searchname or name like :searchname ", {:searchname => args.first}]}):{} }
  named_scope :broker, lambda{|*args| {:conditions => ["broker_id = ?", (args.first)]} }
  named_scope :searchorder, lambda{|*args| {:order => args.first} }
  named_scope :yatchtype, lambda{|*args|(!args.first.blank?)?({:conditions => ["yacht_type in (?)", (args.first)]}):{} }
  named_scope :model_between, lambda { |*args| ((!args.first.blank?) && (!args.last.blank?))?({:conditions => ["making_year >= ? and making_year <= ?", args.first.to_s, args.last.to_s]}):{} }
  named_scope :yachtstatus, :conditions=>["status <> ? and status <> ?",'Archive','Inactive']
  #named_scope :model_between, lambda { |*args| ((!args.first.nil?) && (!args.last.nil?))?({:conditions => ["making_year >= ? and making_year <= ?", args.first.to_s, args.last.to_s]}):{} }

  named_scope :searchinventory, lambda { |*args| (args.size > 0 and !args.first.blank?)?({:conditions => ["builder like :searchname or yacht_type like :searchname or country like :searchname or key_selling_features like :searchname ", {:searchname => args.first}]}):{} }
  named_scope :createdat, lambda { |*args| (!args.first.blank?)? ({:conditions => ["created_at > ? ",args.first.to_s]}):{} }
  named_scope :price_between, lambda { |*args| ((!args.first.blank?) && (!args.last.blank?))?({:conditions => ["price >= ? and price <= ?", args.first.to_i, args.last.to_i]}):{} }  
  named_scope :length_between, lambda { |*args|((!args.first.blank?) && (!args.last.blank?))?({:conditions => ["loa >= ? and loa <= ?", args.first.to_i, args.last.to_i]}):{} }
  named_scope :keyword, lambda { |*args| (args.size > 0 and !args.first.blank?)?({:conditions => ["builder like :searchname or yacht_type like :searchname or city like :searchname or state like :searchname or country like :searchname ", {:searchname => args.first}]}):{} }
  named_scope :ypid, lambda {|*args| (args.size > 0 and !args.first.blank?)?({:conditions => ["ypid = ? ",args.first.to_s]}):{}}  
  named_scope :broker_name, lambda {|*args| (args.size > 0 and !args.first.blank?)?({:conditions => ["broker_id in (?) ",(args.first)]}):{}}  
  
  
  def yachtimage=(input_data)
    if input_data != ""
	    self.image = input_data.read
	    img = Magick::Image.from_blob(self.image)
	    original_height = img[0].rows
	    original_width =  img[0].columns
	    
	    tiny_height = 32  
	    tiny_width = 32   
	    small_height = 85
	    small_width = 85
	    medium_height = 170
	    medium_width = 170
	      
	    if original_height > original_width
	      tiny_width = original_width * tiny_height / original_height
	      small_width = original_width * small_height / original_height
	      medium_width = original_width * medium_height / original_height
	    else
	      tiny_height = original_height * tiny_width / original_width
	      small_height = original_height * small_width / original_width
	      medium_height = original_height * medium_width / original_width
	    end
	      
	    self.photo_small = img[0].thumbnail(small_width, small_height).to_blob
	    self.photo_medium = img[0].thumbnail(medium_width, medium_height).to_blob
    end
  end
  
end
