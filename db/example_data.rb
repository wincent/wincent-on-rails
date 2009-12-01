module FixtureReplacement
  attributes_for :article do |a|
    a.title = random_string
    a.body  = random_string
  end

  attributes_for :attachment do |a|
    a.mime_type         = 'image/png'
    a.original_filename = "#{random_string}.png"
    a.filesize          = rand(1_000_000)
  end

  attributes_for :comment do |c|
    c.user                = new_user
    c.body                = 'hello world'
    c.commentable         = new_article
    c.awaiting_moderation = false
  end

  attributes_for :confirmation do |c|
    c.email = new_email
  end

  attributes_for :email do |e, hash|
    e.address   = "#{random_string}@example.com"
    e.user      = new_user(:email => e) unless hash[:email]
    e.verified  = true
  end

  attributes_for :forum do |f|
    f.name = random_string
  end

  attributes_for :issue do |i|
    i.summary             = random_string
    i.description         = random_string
    i.awaiting_moderation = false
  end

  attributes_for :link do |l|
    l.uri       = "http://#{random_string}/"
    l.permalink = random_string
  end

  attributes_for :message do |m|
    # all fields optional or have default values already
  end

  attributes_for :needle do |n|
    # needles don't use real ActiveRecord associations, so don't even
    # bother creating a real model object for the model fields here
    n.model_class     = 'Article'
    n.model_id        = 5000
    n.attribute_name  = 'body'
    n.content         = 'word'
  end

  attributes_for :page do |p|
    p.title     = random_string
    p.permalink = random_string
    p.body      = "<p>#{random_string}</p>\n"
  end

  attributes_for :post do |p|
    p.title     = random_string
    p.permalink = random_string
    p.excerpt   = random_string
  end

  attributes_for :product do |p|
    p.name      = random_string
    p.permalink = random_string
  end

  attributes_for :reset do |r|
    r.email         = (e = new_email)
    r.user          = e.user
    r.email_address = e.address
  end

  attributes_for :tag do |t|
    t.name = random_string
  end

  attributes_for :tagging do |t|
    t.tag       = new_tag
    t.taggable  = new_article
  end

  attributes_for :topic do |t|
    t.forum               = new_forum
    t.title               = random_string
    t.body                = random_string
    t.awaiting_moderation = false
  end

  attributes_for :tweet do |t|
    t.body = random_string
  end

  PASSPHRASE = 'supersecret'
  attributes_for :user do |u|
    u.display_name            = random_string
    u.passphrase              = PASSPHRASE
    u.passphrase_confirmation = PASSPHRASE
    u.verified                = true
  end

  attributes_for :word do |w|
  end
end
