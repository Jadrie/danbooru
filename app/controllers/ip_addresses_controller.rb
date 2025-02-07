# frozen_string_literal: true

class IpAddressesController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @ip_addresses = authorize IpAddress.visible(CurrentUser.user).paginated_search(params)

    case search_params[:group_by]
    when "ip_addr"
      @ip_addresses = @ip_addresses.group_by_ip_addr(search_params[:ipv4_masklen], search_params[:ipv6_masklen])
    when "user"
      @ip_addresses = @ip_addresses.group_by_user.includes(:user)
    else
      @ip_addresses = @ip_addresses.includes(:user, :model)
    end

    respond_with(@ip_addresses)
  end

  def show
    @ip_address = authorize IpAddress.new(ip_addr: params[:id])
    @ip_info = @ip_address.ip_addr.ip_info
    respond_with(@ip_info)
  end
end
