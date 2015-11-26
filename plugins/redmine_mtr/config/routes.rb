# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'mtr', :to => 'welcome#indexMTR'
match 'mtr/login', :to => 'account#loginMTR'