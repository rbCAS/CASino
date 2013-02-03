# Upgrade CASinoCore

Here is a list of backward-incompatible changes that were introduced.

## 1.x.y

This release adds support for two-factor authentication using a [TOTP](http://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm) (time-based one-time password) which can be generated with applications like [Google Authenticator](http://support.google.com/a/bin/answer.py?hl=en&answer=1037451) (iPhone, Android, BlackBerry) or gadgets such as the [YubiKey](http://www.yubico.com/products/yubikey-hardware/yubikey/).

If you would like to support two-factor authentication in your web application, please have a look at the corresponding processors: `SecondFactorAuthenticationAcceptor`, `TwoFactorAuthenticatorActivator`, `TwoFactorAuthenticatorOverview`, `TwoFactorAuthenticatorRegistrator`

New callbacks:

* `LoginCredentialAcceptor`: calls `#two_factor_authentication_pending` on the listener, when two-factor authentication is enabled for this user.

If you don't want to support two-factor authentication, nothing has to be changed.

## 1.2.0

API changes:

* We extracted user data into an entity. Because of this, attributes such as `username` are no longer accessible directly on a `ticket_granting_ticket`. Use `ticket_granting_ticket.user.username` instead.

## 1.1.0

API changes:

* `LoginCredentialAcceptor`: The parameters of `#process` changed from `params, cookies, user_agent` to just `params, user_agent`

New callbacks:

* `LoginCredentialRequestor` and `LoginCredentialAcceptor` call `#service_not_allowed` on the listener, when a service is not in the service whitelist.
* `API::ServiceTicketProvider` calls `#service_not_allowed_via_api` on the listener, when a service is not in the service whitelist.
