# encoding: utf-8
require 'browser_test_helper'

class ChatTest < TestCase

  def test_basic
    agent = browser_instance
    login(
      browser: agent,
      username: 'master@example.com',
      password: 'test',
      url: browser_url,
    )
    tasks_close_all(
      browser: agent,
    )

    # disable chat
    click(
      browser: agent,
      css: 'a[href="#manage"]',
    )
    click(
      browser: agent,
      css: 'a[href="#channels/chat"]',
    )
    switch(
      browser: agent,
      css: '#content .js-chatSetting',
      type: 'off',
    )
    sleep 25 # wait for rerendering
    click(
      browser: agent,
      css: 'a[href="#customer_chat"]',
    )
    match(
      browser: agent,
      css: '.active.content',
      value: 'disabled',
    )

    customer = browser_instance
    location(
      browser: customer,
      url:     "#{browser_url}/assets/chat/znuny.html?port=#{ENV['WS_PORT']}",
    )
    sleep 4
    exists_not(
      browser: customer,
      css: '.zammad-chat',
    )
    match(
      browser: customer,
      css: '.settings',
      value: '{"state":"chat_disabled"}',
    )
    click(
      browser: agent,
      css: 'a[href="#manage"]',
    )
    click(
      browser: agent,
      css: 'a[href="#channels/chat"]',
    )
    switch(
      browser: agent,
      css: '#content .js-chatSetting',
      type: 'on',
    )
    sleep 15 # wait for rerendering
    switch(
      browser: agent,
      css: '#navigation .js-switch',
      type: 'off',
    )
    click(
      browser: agent,
      css: 'a[href="#customer_chat"]',
      wait: 2,
    )
    match_not(
      browser: agent,
      css: '.active.content',
      value: 'disabled',
    )

    reload(
      browser: customer,
    )
    sleep 4
    exists_not(
      browser: customer,
      css: '.zammad-chat',
    )
    match_not(
      browser: customer,
      css: '.settings',
      value: '{"state":"chat_disabled"}',
    )
    match(
      browser: customer,
      css: '.settings',
      value: '{"event":"chat_status_customer","data":{"state":"offline"}}',
    )
    click(
      browser: agent,
      css: 'a[href="#customer_chat"]',
    )
    switch(
      browser: agent,
      css: '#navigation .js-switch',
      type: 'on',
    )
    reload(
      browser: customer,
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      timeout: 5,
    )
    match_not(
      browser: customer,
      css: '.settings',
      value: '{"state":"chat_disabled"}',
    )
    match_not(
      browser: customer,
      css: '.settings',
      value: '{"event":"chat_status_customer","data":{"state":"offline"}}',
    )
    match(
      browser: customer,
      css: '.settings',
      value: '"data":{"state":"online"}',
    )

    # init chat
    click(
      browser: customer,
      css: '.js-chat-open',
    )
    exists(
      browser: customer,
      css: '.zammad-chat-is-shown',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: '(waiting|warte)',
    )
    watch_for(
      browser: agent,
      css: '.js-chatMenuItem .counter',
      value: '1',
    )
    click(
      browser: customer,
      css: '.js-chat-close',
    )
    watch_for_disappear(
      browser: customer,
      css: '.zammad-chat',
      value: '(waiting|warte)',
    )
    watch_for_disappear(
      browser: agent,
      css: '.js-chatMenuItem .counter',
    )

  end

  def test_basic_usecase1
    agent = browser_instance
    login(
      browser: agent,
      username: 'master@example.com',
      password: 'test',
      url: browser_url,
    )
    tasks_close_all(
      browser: agent,
    )
    click(
      browser: agent,
      css: 'a[href="#customer_chat"]',
    )
    agent.find_elements( { css: '.active .chat-window .js-close' } ).each(&:click)

    customer = browser_instance
    location(
      browser: customer,
      url:     "#{browser_url}/assets/chat/znuny.html?port=#{ENV['WS_PORT']}",
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      timeout: 5,
    )
    click(
      browser: customer,
      css: '.js-chat-open',
    )
    exists(
      browser: customer,
      css: '.zammad-chat-is-shown',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: '(waiting|warte)',
    )

    click(
      browser: agent,
      css: '.active .js-acceptChat',
    )
    sleep 2
    exists_not(
      browser: agent,
      css: '.active .chat-window .chat-status.is-modified',
    )
    set(
      browser: agent,
      css: '.active .chat-window .js-customerChatInput',
      value: 'my name is me',
    )
    click(
      browser: agent,
      css: '.active .chat-window .js-send',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat .zammad-chat-agent-status',
      value: 'online',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: 'my name is me',
    )
    set(
      browser: customer,
      css: '.zammad-chat .zammad-chat-input',
      value: 'my name is customer',
    )
    click(
      browser: customer,
      css: '.zammad-chat .zammad-chat-send',
    )
    watch_for(
      browser: agent,
      css: '.active .chat-window',
      value: 'my name is customer',
    )
    exists(
      browser: agent,
      css: '.active .chat-window .chat-status.is-modified',
    )
    click(
      browser: agent,
      css: '.active .chat-window .js-customerChatInput',
    )
    exists_not(
      browser: agent,
      css: '.active .chat-window .chat-status.is-modified',
    )
    click(
      browser: customer,
      css: '.js-chat-close',
    )
    watch_for(
      browser: agent,
      css: '.active .chat-window',
      value: 'has left the conversation',
    )
  end

  def test_basic_usecase2
    agent = browser_instance
    login(
      browser: agent,
      username: 'master@example.com',
      password: 'test',
      url: browser_url,
    )
    tasks_close_all(
      browser: agent,
    )
    click(
      browser: agent,
      css: 'a[href="#customer_chat"]',
    )
    agent.find_elements( { css: '.active .chat-window .js-close' } ).each(&:click)

    customer = browser_instance
    location(
      browser: customer,
      url:     "#{browser_url}/assets/chat/znuny.html?port=#{ENV['WS_PORT']}",
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      timeout: 5,
    )
    click(
      browser: customer,
      css: '.js-chat-open',
    )
    exists(
      browser: customer,
      css: '.zammad-chat-is-shown',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: '(waiting|warte)',
    )
    click(
      browser: agent,
      css: '.active .js-acceptChat',
    )
    sleep 2
    exists_not(
      browser: agent,
      css: '.active .chat-window .chat-status.is-modified',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat .zammad-chat-agent-status',
      value: 'online',
    )
    set(
      browser: customer,
      css: '.zammad-chat .zammad-chat-input',
      value: 'my name is customer',
    )
    click(
      browser: customer,
      css: '.zammad-chat .zammad-chat-send',
    )
    watch_for(
      browser: agent,
      css: '.active .chat-window',
      value: 'my name is customer',
    )
    sleep 1
    exists(
      browser: agent,
      css: '.active .chat-window .chat-status.is-modified',
    )
    set(
      browser: agent,
      css: '.active .chat-window .js-customerChatInput',
      value: 'my name is me',
    )
    exists_not(
      browser: agent,
      css: '.active .chat-window .chat-status.is-modified',
    )
    click(
      browser: agent,
      css: '.active .chat-window .js-send',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: 'my name is me',
    )
    click(
      browser: agent,
      css: '.active .chat-window .js-close',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat .zammad-chat-agent-status',
      value: 'offline',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: 'Chat closed by',
    )
  end

  def test_timeouts
    customer = browser_instance
    location(
      browser: customer,
      url:     "#{browser_url}/assets/chat/znuny.html?port=#{ENV['WS_PORT']}",
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      timeout: 5,
    )
    watch_for_disappear(
      browser: customer,
      css: '.zammad-chat',
      timeout: 75,
    )
    reload(
      browser: customer,
    )
    exists(
      browser: customer,
      css: '.zammad-chat',
    )
    click(
      browser: customer,
      css: '.js-chat-open',
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: '(waiting|warte)',
      timeout: 35,
    )
    watch_for(
      browser: customer,
      css: '.zammad-chat',
      value: '(takes longer|dauert länger)',
      timeout: 90,
    )

  end

end
