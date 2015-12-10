# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'mtr', :to => 'mtr_welcome#mtr_index', :as => 'home'
match 'mtr/login', :to => 'mtr_account#mtr_login'