module Sinatra
  module Doorman
    Messages = {
      :signup_success => 'You have signed up successfully. A confirmation ' +
        'email has been sent to you.',
      :confirm_no_token => 'Invalid confirmation URL.  Please make sure you ' +
        'have the correct link from the email.',
      :confirm_no_user => 'Invalid confirmation URL.  Please make sure you ' +
        'have the correct link from the email, and are not already confirmed.',
      :confirm_success => 'You have successfully confirmed your account. ' +
        'Please log in.',
      # Auto login upon confirmation?
      :login_bad_credentials => 'Invalid Login and Password. Please try again.',
      :login_not_confirmed => 'You must confirm your account before you can ' +
        'log in. Please click the confirmation link sent to you.',
      # Note: resend confirmation link?
      :logout_success => 'You have been logged out.',
      :forgot_no_user => 'There is no user with that Username or Email. ' +
        'Please try again.',
      :forgot_success => 'An email with instructions to reset your password ' +
        'has been sent to you.',
      :reset_no_token => 'Invalid reset URL.  Please make sure you ' +
        'have the correct link from the email.',
      :reset_no_user => 'Invalid reset URL.  Please make sure you have the ' +
        'correct link from the email, and have already reset the password.',
      :reset_unmatched_passwords => 'Password and confirmation do not match. ' +
        'Please try again.',
      :reset_success => 'Your password has been reset.'
    }
  end
end
