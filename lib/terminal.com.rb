# This is the low-level version of Terminal.com API.
# All it does is 1:1 mapping of Ruby methods to the API.
#
# If you want a more user-friendly, object-oriented API,
# do use terminal.com/api.rb.

require 'net/http'
require 'json'

module Terminal
  VERSION = '0.0.1'

  API_VERSION = 'v0.1'
  HEADERS = {'Content-Type' => 'application/json'}

  ############################
  # BROWSE SNAPSHOTS & USERS #
  ############################

  # Get information on a snapshot.
  #
  # @param snapshot_id [String] Snapshot ID.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#get-snapshot
  def self.get_snapshot(snapshot_id)
    call('/get_snapshot', snapshot_id: snapshot_id)
  end

  # Get information on a user.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#get-profile
  def self.get_profile(username)
    call('/get_profile', username: username)
  end

  # Get a list of public snapshots, optionally filtered by the owner's username, a tag, or the snapshot's featured status. You may use a combination of filters.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#list-public-snapshots
  # sortby options: 'popularity', 'date'
  def self.list_public_snapshots(**options)
    ensure_options_validity(options,
      :username, :tag, :featured, :title, :page, :perPage, :sortby)

    call('/list_public_snapshots', options)
  end

  # Get a count of public snapshots, optionally filtered by the owner's username, a tag, or the snapshot's featured status. You may use a combination of filters.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#count-public-snapshots
  def self.count_public_snapshots(**options)
    ensure_options_validity(options,
      :username, :tag, :featured, :title)

    call('/count_public_snapshots', options)
  end

  ###############################
  # CREATE AND MANAGE TERMINALS #
  ###############################

  # Get a list of all Terminal instances owned by your account.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#list-terminals
  def self.list_terminals(user_token, access_token)
    call('/list_terminals',
      user_token: user_token, access_token: access_token)
  end

  # Get info about a Terminal instance of yours.  Can specify container_key, ctid, or subdomain.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#get-terminal
  def self.get_terminal(user_token, access_token, **options)
    ensure_options_validity(options, :container_key, :subdomain)

    options.merge!(user_token: user_token, access_token: access_token)

    call('/get_terminal', options)
  end

  # Start a Terminal instance based on a snapshot.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#start-snapshot
  def self.start_snapshot(user_token, access_token, snapshot_id, **options)
    if (options[:cpu] && ! options[:ram]) || (options[:ram] && ! options[:cpu])
      raise ArgumentError.new('You have to specify both cpu and ram of the corresponding instance type as described at https://www.terminal.com/faq#instanceTypes')
    end

    ensure_options_validity(options,
      :cpu, :ram, :temporary, :name, :autopause, :startup_script, :custom_data)

    options.merge!(user_token: user_token, access_token: access_token, snapshot_id: snapshot_id)

    call('/start_snapshot', options)
  end

  # Delete a Terminal instance.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#delete-terminal
  def self.delete_terminal(user_token, access_token, container_key)
    call('/delete_terminal',
      user_token: user_token, access_token: access_token, container_key: container_key)
  end

  # Reboot a Terminal instance.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#restart-terminal
  def self.restart_terminal(user_token, access_token, container_key)
    call('/restart_terminal',
      user_token: user_token, access_token: access_token, container_key: container_key)
  end

  # Pause a Terminal instance. The instance will be offline and inaccessible, and you will not be charged as long as it remains paused.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#pause-terminal
  def self.pause_terminal(user_token, access_token, container_key)
    call('/pause_terminal',
      user_token: user_token, access_token: access_token, container_key: container_key)
  end

  # Continue running a Terminal instance. The Terminal will continue being charged, and will keep running so long as you maintain a positive balance in your account.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#resume-terminal
  def self.resume_terminal(user_token, access_token, container_key)
    call('/resume_terminal',
      user_token: user_token, access_token: access_token, container_key: container_key)
  end

  # Edit the resources and/or name of a Terminal instance.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#edit-terminal
  def self.edit_terminal(user_token, access_token, container_key, **options)
    ensure_options_validity(options,
      :cpu, :ram, :diskspace, :name)

    options.merge!(user_token: user_token, access_token: access_token, container_key: container_key)

    call('/edit_terminal', options)
  end

  ###############################
  # CREATE AND MANAGE SNAPSHOTS #
  ###############################

  # Get a list of snapshots owned by your account, optionally filtered by the owner's username, a tag, or the snapshot's featured status. You may use a combination of filters.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#list-snapshots
  def self.list_snapshots(user_token, access_token, **options)
    ensure_options_validity(options,
      :username, :tag, :featured, :title, :page, :perPage)

    options.merge!(user_token: user_token, access_token: access_token)

    call('/list_snapshots', options)
  end

  # Get a count of snapshots owned by your account, optionally filtered by the owner's username, a tag, or the snapshot's featured status. You may use a combination of filters.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#count-snapshots
  def self.count_snapshots(user_token, access_token, **options)
    ensure_options_validity(options,
      :username, :tag, :featured, :title)

    options.merge!(user_token: user_token, access_token: access_token)

    call('/count_snapshots', options)
  end

  # Delete a snapshot from your account. This cannot be undone.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#delete-snapshot
  def self.delete_snapshot(user_token, access_token, snapshot_id)
    call('/delete_snapshot',
      user_token: user_token,
      access_token: access_token,
      snapshot_id: snapshot_id)
  end

  # Edit the metadata of a snapshot owned by your account.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#edit-snapshot
  def self.edit_snapshot(user_token, access_token, snapshot_id, **options)
    ensure_options_validity(options,
      :body, :title, :readme, :tags, :public, :custom_data)

    options.merge!(user_token: user_token, access_token: access_token, snapshot_id: snapshot_id)

    call('/edit_snapshot', options)
  end

  # Create a snapshot of a Terminal instance.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#snapshot-terminal
  def self.snapshot_terminal(user_token, access_token, container_key, **options)
    ensure_options_validity(options,
      :body, :title, :readme, :tags, :public)

    options.merge!(user_token: user_token, access_token: access_token, container_key: container_key)

    call('/snapshot_terminal', options)
  end

  ##########################
  # MANAGE TERMINAL ACCESS #
  ##########################

  # Add to the list of your other terminals who have access to one of your Terminal instances.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#add-terminal-links
  def self.add_terminal_links(user_token, access_token, container_key, *links)
    call('/add_terminal_links',
      user_token: user_token,
      access_token: access_token,
      container_key: container_key,
      links: links)
  end

  # Remove from the list of terminals who have access to one of your Terminal instances.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#remove-terminal-links
  def self.remove_terminal_links(user_token, access_token, container_key, *links)
    call('/remove_terminal_links',
      user_token: user_token,
      access_token: access_token,
      container_key: container_key,
      links: links)
  end

  # List users and emails with view or edit access to one of your Terminal instances.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#list-terminal-access
  def self.list_terminal_access(user_token, access_token, container_key)
    call('/list_terminal_access',
      user_token: user_token,
      access_token: access_token,
      container_key: container_key)
  end

  # Edit the list of users and emails who have access to one of your Terminal instances.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#edit-terminal-access
  def self.edit_terminal_access(user_token, access_token, container_key, **options)
    ensure_options_validity(options, :is_public_list, :access_rules)

    options.merge!(user_token: user_token, access_token: access_token, container_key: container_key)

    call('/edit_terminal_access', options)
  end

  #################################
  # MANAGE TERMINAL DNS & DOMAINS #
  #################################

  # Get a list of domains in your CNAME record pool. Domains returned by this call can be associated to your Terminal instances.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#get-cname-records
  def self.get_cname_records(user_token, access_token)
    call('/get_cname_records',
      user_token: user_token, access_token: access_token)
  end

  # Add a domain or subdomain of Terminal.com to your CNAME record pool, making it available to be associated with one of your Terminal instances.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#add-domain-to-pool
  def self.add_domain_to_pool(user_token, access_token, domain)
    call('/add_domain_to_pool',
      user_token: user_token, access_token: access_token, domain: domain)
  end

  # Remove a domain or subdomain of Terminal.com from your CNAME record pool.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#remove-domain-from-pool
  def self.remove_domain_from_pool(user_token, access_token, domain)
    call('/remove_domain_from_pool',
      user_token: user_token, access_token: access_token, domain: domain)
  end

  # Map a domain in your CNAME record pool to one of your Terminal instances, making it accessible via that domain.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#add-cname-record
  def self.add_cname_record(user_token, access_token, domain, subdomain, port)
    call('/add_cname_record',
      user_token: user_token,
      access_token: access_token,
      domain: domain,
      subdomain: subdomain,
      port: port)
  end

  # Remove a domain mapping to one of your Terminal instances. This will mean you can no longer access the Terminal instance from that domain.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#remove-cname-record
  def self.remove_cname_record(user_token, access_token, domain)
    call('/remove_cname_record',
      user_token: user_token,
      access_token: access_token,
      domain: domain)
  end

  #################################
  # MANAGE TERMINAL IDLE SETTINGS #
  #################################

  # Set the idle settings for your Terminal.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#set-terminal-idle-settings
  def self.set_terminal_idle_settings(user_token, access_token, container_key, action, *triggers)
    call('/set_terminal_idle_settings',
      user_token: user_token,
      access_token: access_token,
      container_key: container_key,
      action: action,
      triggers: triggers)
  end

  # Get the idle settings for your terminal.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#get-terminal-idle-settings
  def self.get_terminal_idle_settings(user_token, access_token, container_key)
    call('/get_terminal_idle_settings',
      user_token: user_token,
      access_token: access_token,
      container_key: container_key)
  end

  ##########################
  # MANAGE USAGE & CREDITS #
  ##########################

  # Get a list of the types of Terminals that may be started, and the specifications for each type (CPU, RAM, and pricing). This endpoint does not require authentication.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#instance-types
  def self.instance_types
    call('/instance_types', Hash.new)
  end

  # Get the hourly pricing for a Terminal instance of a given type.  If a instance is stopped, price will be zero.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#instance-price
  def self.instance_price(instance_type, status = 'running')
    call('/instance_price', instance_type: instance_type, status: status)
  end

  # Get the current balance of your account.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#balance
  def self.balance(user_token, access_token)
    call('/balance', user_token: user_token, access_token: access_token)
  end

  # Get a history of credits added to your account balance.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#balance-added
  def self.balance_added(user_token, access_token)
    call('/balance_added', user_token: user_token, access_token: access_token)
  end

  # Gift some of your credits to another user. Denominated in whole integer US cents ($0.01). You may only gift credits if you have previously purchased credits.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#gift
  def self.gift(user_token, access_token, email, cents)
    call('/gift',
      user_token: user_token,
      access_token: access_token,
      email: email,
      cents: cents)
  end

  # Get a history of charges to your account balance.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#burn-history
  def self.burn_history(user_token, access_token)
    call('/burn_history', user_token: user_token, access_token: access_token)
  end

  # Get a history of your Terminal usage.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#terminal-usage-history
  def self.terminal_usage_history(user_token, access_token)
    call('/terminal_usage_history', user_token: user_token, access_token: access_token)
  end

  # Get a summary of current active charges being billed to your account.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#burn-state
  def self.burn_state(user_token, access_token)
    call('/burn_state', user_token: user_token, access_token: access_token)
  end

  # Get a summary of the charges to your account, based on each Terminal instance that you have provisioned. Note that inactive and paused terminals do not incur charges.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#burn-estimates
  def self.burn_estimates(user_token, access_token)
    call('/burn_estimates', user_token: user_token, access_token: access_token)
  end

  ##########################
  # MANAGE SSH PUBLIC KEYS #
  ##########################

  # Add an SSH public key to a given Terminal's root user.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#add-authorized-key-to-terminal
  def self.add_authorized_key_to_terminal(user_token, access_token, container_key, publicKey)
    call('/add_authorized_key_to_terminal',
      user_token: user_token,
      access_token: access_token,
      container_key: container_key,
      publicKey: publicKey)
  end

  # Add an SSH public key to our SSH proxy.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#add-authorized-key-to-ssh-proxy
  def self.add_authorized_key_to_ssh_proxy(user_token, access_token, name, publicKey)
    call('/add_authorized_key_to_ssh_proxy',
      user_token: user_token,
      access_token: access_token,
      name: name,
      publicKey: publicKey)
  end

  # Delete an SSH public key from our SSH proxy.
  #
  # @param user_token   [String] Your user token.
  # @param access_token [String] Your access token.
  # @param name         [String] TODO.
  # @param fingerprint  [String] TODO.
  # @return [Hash] xxx
  # @see https://www.terminal.com/api/docs#del-authorized-key-from-ssh-proxy
  def self.del_authorized_key_from_ssh_proxy(user_token, access_token, name, fingerprint)
    call('/del_authorized_key_from_ssh_proxy',
      user_token: user_token,
      access_token: access_token,
      name: name,
      fingerprint: fingerprint)
  end

  # List the SSHs public key on our SSH proxy.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#get-authorized-keys-from-ssh-proxy
  def self.get_authorized_keys_from_ssh_proxy(user_token, access_token)
    call('/get_authorized_keys_from_ssh_proxy',
      user_token: user_token, access_token: access_token)
  end

  #########
  # OTHER #
  #########

  # Get information about yourself!  If invalid access/user token provided, returns null (but not an error).
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#who-am-i
  def self.who_am_i(user_token, access_token)
    call('/who_am_i', user_token: user_token, access_token: access_token)
  end

  # Get info and status of an API request.
  #
  # @param xxx [String] desc.
  # @return [Hash] desc.
  # @see https://www.terminal.com/api/docs#request-progress
  def self.request_progress(request_id)
    call('/request_progress', request_id: request_id)
  end

  # @api private
  def self.request
    @request ||= Net::HTTP.new('api.terminal.com')
  end

  # @api public
  def self.call(path, data)
    path = "/#{API_VERSION}#{path}"
    json = data.to_json

    curl_debug(path, data.to_json)

    response = request.post(path, json, HEADERS)
    status   = response.code.to_i

    return JSON.parse(response.body) if status == 200

    raise "Unexpected status #{status}: #{response.inspect}"
  end

  def self.curl_debug(path, json)
    return if ENV['DBG'].nil?

    headers = HEADERS.reduce(Array.new) do |buffer, (key, value)|
      buffer << "#{key}: #{value}"
    end.join(' ')

    STDERR.puts <<-EOF
curl -L -X POST -H '#{headers}' -d '#{json}' https://api.terminal.com#{path}
    EOF
  end

  def self.ensure_options_validity(options, *valid_keys)
    unrecognised_options = (options.keys - valid_keys)

    unless unrecognised_options.empty?
      raise ArgumentError.new("Unrecognised options: #{unrecognised_options.inspect[1..-2]}")
    end
  end
end
