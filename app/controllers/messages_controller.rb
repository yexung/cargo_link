class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trade, only: [:index, :create]
  before_action :set_message, only: [:show]

  def index
    # 거래의 모든 메시지 조회
    @messages = @trade.messages.includes(:sender).order(created_at: :asc)
    @new_message = Message.new
    
    # 권한 확인 - 거래 당사자만 메시지 볼 수 있음
    unless can_access_trade?
      redirect_to trades_path, alert: '권한이 없습니다.'
      return
    end
  end

  def show
    @message = Message.find(params[:id])
    @trade = @message.trade
    
    # 권한 확인
    unless can_access_trade?
      redirect_to trades_path, alert: '권한이 없습니다.'
      return
    end
  end

  def create
    @message = @trade.messages.build(message_params)
    @message.sender = current_user_for_message
    @message.receiver = get_receiver
    @message.sent_at = Time.current

    # 권한 확인
    unless can_access_trade?
      redirect_to trades_path, alert: '권한이 없습니다.'
      return
    end

    if @message.save
      if request.xhr?
        render json: {
          success: true,
          message: '메시지가 전송되었습니다.',
          html: render_to_string(partial: 'messages/message', locals: { message: @message })
        }
      else
        redirect_to trade_messages_path(@trade), notice: '메시지가 전송되었습니다.'
      end
    else
      if request.xhr?
        render json: {
          success: false,
          message: @message.errors.full_messages.join(', ')
        }
      else
        redirect_to trade_messages_path(@trade), alert: @message.errors.full_messages.join(', ')
      end
    end
  end

  private

  def set_trade
    @trade = Trade.find(params[:trade_id])
  end

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def can_access_trade?
    current_user_for_message == @trade.seller || current_user_for_message == @trade.buyer
  end

  def current_user_for_message
    # 현재 로그인한 사용자 반환 (seller, buyer, admin_user 중 하나)
    return current_seller if seller_signed_in?
    return current_buyer if buyer_signed_in?
    return current_admin_user if admin_user_signed_in?
    nil
  end

  def get_receiver
    # 메시지 수신자 결정
    current_sender = current_user_for_message
    if current_sender == @trade.seller
      @trade.buyer
    elsif current_sender == @trade.buyer
      @trade.seller
    else
      nil
    end
  end

  def authenticate_user!
    unless seller_signed_in? || buyer_signed_in? || admin_user_signed_in?
      redirect_to root_path, alert: '로그인이 필요합니다.'
    end
  end
end 