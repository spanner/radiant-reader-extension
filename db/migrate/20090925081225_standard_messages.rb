class StandardMessages < ActiveRecord::Migration
  def self.up
    Message.reset_column_information
    messages = []
    
    messages.push(Message.create(
      :subject => 'Welcome!',
      :function => 'welcome',
      :filter_id => nil,
      :body => %{
<p>Hello <r:recipient:name />.</p>

<p>Welcome to the <strong><a href="<r:site:url />"><r:site:name /></a></strong> site, and thank you for persevering with the registration process. Your account is now active and you will have been logged in automatically.</p>

<p>You can put in a bit more information about yourself at any time by visiting <a href="<r:recipient:edit_url />">your preferences page</a>.</p>

<p>Next time you visit, you will need to log in. Here's another reminder before we discard the plain text version of your password:</p>

<ul>
  <li>username: <strong><r:recipient:login /></strong></li>
  <li>password: <strong><r:recipient:password /></strong></li>
</ul>

<p>Best wishes,</p>

<p><r:sender:name /></p>
      }
    ))
    
    messages.push(Message.create(
      :subject => 'Please activate your account',
      :function => 'activation',
      :filter_id => nil,
      :body => %{
<p>Hello <r:recipient:name />.</p>

<p>Welcome! Your account has been created at the <strong><r:site:name /></strong> site. To activate it, all you have to do is <strong><a href="<r:recipient:activation_url />">click on this link</a></strong>.</p>

<p>On this first visit you'll be logged in automatically, but next time you'll need to know your username and password:</p>

<ul>
<li>username: <strong><r:recipient:login /></strong></li>
<li>password: <strong><r:recipient:password /></strong></li>
</ul>

<p>To see yourself as others might see you, have a look at <a href="<r:recipient:url />">your page</a>. You can change that listing in your <a href="<r:recipient:edit_url />">preferences</a> and if you'd like a picture to appear, you need a <a href="http://www.gravatar.com/signup">gravatar</a>.</p>

<p>We're about to forget your password, so we won't be able to remind you what it is, but if you get stuck you can always make a new one by clicking on the 'forgot my password' link on the login page.</p>

<p>Best wishes,</p>

<p><r:sender:name /></p>
      }  
    ))
    
    messages.push(Message.create(
      :subject => 'You are invited!',
      :function => 'invitation',
      :filter_id => nil,
      :body => %{
<p>Hello <r:recipient:name />.</p>

<p>You are invited to join the <strong><r:site:name /></strong> site. To accept the invitation, all you have to do is  <strong><a href="<r:recipient:activation_url />">click on this link</a></strong>.</p>

<p>On this first visit you'll be logged in automatically, but next time you'll need to know your username and password. Most of this has been generated automatically:</p>

<ul>
  <li>username: <strong><r:recipient:login /></strong></li>
  <li>password: <strong><r:recipient:password /></strong></li>
</ul>

So you will want to change it in your <a href="<r:recipient:edit_url />">preferences</a>, where you can also edit the text that will appear on your <a href="<r:recipient:url />">listing page</a> whenever someone follows a link from one of your contributions to the site.</p>

<p>Once you've logged in we'll forget your password, so we won't be able to remind you what it is. If you get stuck you can always make a new one by clicking on the 'forgot my password' link on the login page.</p>

<p>Best wishes,</p>

<p><r:sender:name /></p>
      }  
    ))

    messages.push(Message.create(
      :subject => 'Reset your password',
      :function => 'password_reset',
      :filter_id => nil,
      :body => %{
<p>Hello <r:recipient:name />.</p>

<p>Someone has requested that a new password be generated for your account at the <strong><a href="<r:site:url />"><r:site:name /></a></strong> site. If that person wasn't you, please don't be concerned: you are seeing this message, not they, and your password hasn't changed. You can safely delete this message and forget about it.</p>

<p>If that person was you, please <strong><a href="<r:recipient:repassword_url />">click here to enter a new password</a></strong>. Nothing will actually change until you submit the password-reset form.</p>

<p>If you have remembered your current password and all you want to do is change it, you can skip this step and go straight to your <a href="<r:recipient:edit_url />">preferences</a>.</p>
      }  
    ))
    
    if admin = User.find_by_admin(true)
      messages.each do |message|
        message.update_attribute(:created_by_id, admin.id)
      end
    end
  end

  def self.down
  end
end
