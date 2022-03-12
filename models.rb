require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    has_many :posts
    has_many :favorites
    has_many :favorite_posts, through: :favorites, source: :post, dependent: :destroy
    has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
    has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
    has_many :followings, through: :relationships, source: :relationship
    has_many :followers, through: :reverse_of_relationships, source: :relationship
    has_many :comments
    has_many :comment_posts, through: :comments, source: :post, dependent: :destroy

end

class Post < ActiveRecord::Base
    belongs_to :user
    has_many :favorites
    has_many :favorite_users, through: :favorites, source: :user, dependent: :destroy
    has_many :comments
    has_many :comment_users, through: :comments, source: :user, dependent: :destroy
end

class Favorite < ActiveRecord::Base
    belongs_to :user
    belongs_to :post
end

class Relationship < ActiveRecord::Base
    belongs_to :follower, class_name: 'User'
    belongs_to :followed, class_name: 'User'
end

class Comment < ActiveRecord::Base
    belongs_to :user  #Comment.userでコメントの所有者を取得
    belongs_to :post  #Comment.postでそのコメントがされた投稿を取得
end


    