users = [
  { username: 'fuga', passwd: 'e6da8c345d56443958171fa36bf60140ec6aa724a8184b2b29d3004e9f390ccc', email: 'fuga@r0uei.dev' },
  { username: 'yu1hpa', passwd: 'd4fa46e80b7a532cdbd4ecc6e669cd37ccddf23f33abade2f7772e75473053d1', email: 'yu1hpa@r0uei.dev' }
]

users.each do |u|
  User.create(u)
end
