module ApplicationHelper

 #Returns the full title on a per-page basis.
 def full_title(page_title = '')
   basic_title = "Ruby on Rails Tutorial Sample App"
   if page_title.empty?
   	basic_title
   else
     page_title + ' | ' + basic_title
   end
 end 
end
