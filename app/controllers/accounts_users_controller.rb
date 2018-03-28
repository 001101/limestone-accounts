class AccountsUsersController < ApplicationController
  before_action :set_accounts_user, only: [:destroy]

  def destroy
    authorize @accounts_user
    @accounts_user.discard
    flash[:success] = "The user #{@accounts_user.full_name} <#{@accounts_user.email}> has been removed from your account."
    redirect_to account_show_path
  end

  private

    def set_accounts_user
      @accounts_user = AccountsUser.find(params[:id])
    end
end
