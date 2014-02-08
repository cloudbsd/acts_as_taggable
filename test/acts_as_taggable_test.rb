require 'test_helper'

class ActsAsTaggableTest < ActiveSupport::TestCase
  setup do
    3.times do |i|
      User.create(name: "user#{i+1}")
    end
    3.times do |i|
      Blog.create(title: "blog title #{i+1}")
    end
    3.times do |i|
      Post.create(title: "post title #{i+1}")
    end
    ['vector', 'list', 'deque'].each do |tag|
      ActsAsTaggable::Tag.create(name: tag, user: User.all[0])
    end
  end

  test "module 'ActsAsTaggable' is existed" do
    assert_kind_of Module, ActsAsTaggable
  end

  test "acts_as_tagger method is available" do
    assert User.respond_to? :acts_as_tagger
    assert User.respond_to? :acts_as_tagger_on
  end

  test "acts_as_taggable method is available" do
    assert Blog.respond_to? :acts_as_taggable
    assert Blog.respond_to? :acts_as_taggable_by
    assert Post.respond_to? :acts_as_taggable
    assert Post.respond_to? :acts_as_taggable_by
  end

  test "tag?/tag/untag methods are available" do
    user = User.first
    assert user.respond_to? :tag?
    assert user.respond_to? :tag
    assert user.respond_to? :untag
  end

  test "method 'acts_as_tagger' is available" do
    user1, user2 = User.all[0], User.all[1];
    post1, post2 = Post.all[0], Post.all[1];
    tag1,  tag2  = ActsAsTaggable::Tag.all[0], ActsAsTaggable::Tag.all[1];

    assert_equal(false, user1.tag?(tag1, post1, 'favorite'))
    user1.tag(tag1, post1, 'favorite')
    assert_equal(true, user1.tag?(tag1, post1, 'favorite'))
    assert_equal 1, ActsAsTaggable::Tagging.all.count
    assert_equal 1, user1.taggings.count

    user1.tag(tag2, post2, 'favorite')
    assert_equal(true, user1.tag?(tag2, post2, 'favorite'))
    assert_equal 2, user1.taggings.count

    user1.tag(tag1, post2, 'read')
    assert(user1.tag?(tag1, post2, 'read'))
    assert_equal 3, user1.taggings.count
    assert_equal 2, user1.taggings.where(context: 'favorite').count
    assert_equal 1, user1.taggings.where(context: 'read').count

    user1.untag(tag1, post2, 'read')
    assert(!user1.tag?(tag1, post2, 'read'))
    assert_equal 2, user1.taggings.count

    user1.untag(tag2, post2, 'favorite')
    assert_equal(false, user1.tag?(tag2, post2, 'favorite'))
    assert_equal 1, user1.taggings.count

    user1.untag(tag1, post1, 'favorite')
    assert_equal(false, user1.tag?(tag1, post1, 'favorite'))
    assert_equal 0, user1.taggings.count
  end

=begin
  test "method 'acts_as_tagger_on' is available" do
    user1, user2 = User.all[0], User.all[1];
    post1, post2 = Post.all[0], Post.all[1];

    assert_equal 0, user1.favorite_posts_taggings.count
    assert_equal 0, user1.favorite_posts.count
    user1.tag(post1, 'favorite')
    assert_equal 1, user1.taggings.where(context: 'favorite').size
    assert_equal 1, user1.favorite_posts_taggings.count
    assert_equal 1, user1.favorite_posts.count

    assert_equal 0, user1.read_posts_taggings.count
    assert_equal 0, user1.read_posts.count
    user1.tag(post1, 'read')
    assert_equal 1, user1.taggings.where(context: 'read').size
    assert_equal 1, user1.read_posts_taggings.count
    assert_equal 1, user1.read_posts.count

    assert_equal 2, user1.taggings.size
  end
=end

  test "method 'acts_as_taggable_by' is available" do
    user1, user2 = User.all[0], User.all[1];
    post1, post2 = Post.all[0], Post.all[1];
    tag1, tag2, tag3  = ActsAsTaggable::Tag.all[0], ActsAsTaggable::Tag.all[1], ActsAsTaggable::Tag.all[2];

    assert_equal 0, post1.favorite_taggings.count
    assert_equal 0, post1.favorite_tags.count
  # user1.tag(tag1, post1, 'favorite')
    post1.favorite_by tag1, user1
    assert_equal 1, post1.taggings.where(context: 'favorite').size
    assert_equal 1, post1.favorite_taggings.count
    assert_equal 1, post1.favorite_tags.count

    p post1.favorite_taggings.size
    p post1.favorite_tags.count
    p post1.favorite_tag_list

  # user1.tag(tag2, post1, 'favorite')
    post1.favorite_by tag2, user1
    p post1.favorite_taggings.size
    p post1.favorite_tags.count
    p post1.favorite_tag_list

    post1.favorite_tag_list = 'ruby, rails, gems'
    p post1.favorite_taggings.size
    p post1.favorite_tags.count
    p post1.favorite_tag_list

    tagging = post1.tag_by tag3, user1, 'favorite'
    p post1.favorite_taggings.size
  # post1.favorite_taggings << tagging
    p post1.favorite_tags.count
    p post1.favorite_tag_list
  # p post1.favorite_tags << tag3

  # assert_equal 0, post1.read_users_taggings.count
  # assert_equal 0, post1.read_users.count
  # user1.tag(post1, 'read')
  # assert_equal 1, post1.taggings.where(context: 'read').size
  # assert_equal 1, post1.read_users_taggings.count
  # assert_equal 1, post1.read_users.count

  # assert_equal 2, post1.taggings.size
  end

=begin
  test "generated methods by 'acts_as_tagger_on' are available" do
    user1, user2 = User.all[0], User.all[1];
    post1, post2 = Post.all[0], Post.all[1];

    assert_equal 0, user1.favorite_posts_taggings.count
    assert_equal 0, user1.favorite_posts.count

    assert_equal false, user1.favorite?(post1)
    user1.favorite(post1)
    assert_equal true, user1.favorite?(post1)

    user1.favorite(post2)
    assert_equal 2, user1.taggings.where(context: 'favorite').size
    assert_equal 2, user1.favorite_posts_taggings.count
    assert_equal 2, user1.favorite_posts.count

    user1.unfavorite(post2)
    assert_equal 1, user1.taggings.where(context: 'favorite').size
    assert_equal 1, user1.favorite_posts_taggings.count
    assert_equal 1, user1.favorite_posts.count

    assert_equal 0, user1.read_posts_taggings.count
    assert_equal 0, user1.read_posts.count

    user1.read(post1)
    assert_equal 1, user1.taggings.where(context: 'read').size
    assert_equal 1, user1.read_posts_taggings.count
    assert_equal 1, user1.read_posts.count

    assert_equal 2, user1.taggings.size
  end

  test "generated methods 'acts_as_taggable_by' are available" do
    user1, user2 = User.all[0], User.all[1];
    post1, post2 = Post.all[0], Post.all[1];

    assert_equal 0, post1.favorite_users_taggings.count
    assert_equal 0, post1.favorite_users.count

    assert_equal false, post1.favorite_by?(user1)
    post1.favorite_by user1
    assert_equal true, post1.favorite_by?(user1)

    assert_equal 1, post1.taggings.where(context: 'favorite').size
    assert_equal 1, post1.favorite_users_taggings.count
    assert_equal 1, post1.favorite_users.count

    post1.unfavorite_by user1
    assert_equal false, post1.favorite_by?(user1)

    assert_equal 0, post1.read_users_taggings.count
    assert_equal 0, post1.read_users.count
    user1.tag(post1, 'read')
    assert_equal 1, post1.taggings.where(context: 'read').size
    assert_equal 1, post1.read_users_taggings.count
    assert_equal 1, post1.read_users.count

    assert_equal 1, post1.taggings.size
  end

  test "using same context for blog and post works" do
    user1, user2 = User.all[0], User.all[1];
    blog1, blog2 = Blog.all[0], Blog.all[1];
    post1, post2 = Post.all[0], Post.all[1];

    assert_equal 0, user1.favorite_posts_taggings.count
    assert_equal 0, user1.favorite_posts.count

    assert_equal false, user1.favorite?(blog1)
    assert_equal false, user1.favorite?(post1)
    user1.favorite(blog1)
    user1.favorite(post1)
    assert_equal true, user1.favorite?(blog1)
    assert_equal true, user1.favorite?(post1)

    assert_equal 2, user1.taggings.size
    assert_equal 2, user1.taggings.where(context: 'favorite').size
    assert_equal 2, user1.favorite_taggings.count
    assert_equal 1, user1.favorite_blogs_taggings.count
    assert_equal 1, user1.favorite_blogs.count
    assert_equal 1, user1.favorite_posts_taggings.count
    assert_equal 1, user1.favorite_posts.count
  end
=end
end
