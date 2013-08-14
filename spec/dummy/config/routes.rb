Dummy::Application.routes.draw do
  mount CASino::Engine => '/', :as => 'casino'

  mount CASino::Engine => '/', :as => 'CASino'

end
