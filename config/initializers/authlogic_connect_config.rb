# connections = {}
# %w{twitter facebook google yahoo myspace vimeo linked_in}.each do |provider|
#   if Radiant.config["reader.#{provider}.key"]
#     connect[provider] = {
#       :key => Radiant.config["reader.#{provider}.key"],
#       :secret => Radiant.config["reader.#{provider}.secret"],
#       :label => provider.titlecase
#     }
#   end
# end
# 
# AuthlogicConnect.config = connections
