angular.module 'mnoEnterpriseAngular'
  .controller('AppsManagementCtrl',
    ($q, MnoeConfig, MnoeAppInstances, MnoeProvisioning, MnoeOrganizations) ->

      vm = @
      vm.isLoading = true

      # TODO: Add apps reload feature when organization is changed from
      #       company select box.

      vm.providesStatus = (app) ->
        vm.dataSharingEnabled(app) || app.subscription

      vm.dataSharingEnabled = (app) ->
        MnoeConfig.isDataSharingEnabled() && app.data_sharing

      # TODO: Decide how data sharing status is checked
      vm.dataSharingStatus = (app) ->
        if app.sync_status?.status
          'Connected'
        else
          'Disconnected'

      vm.subscriptionStatus = (app) ->
        return app.subscription.status if app.subscription

      vm.appActionUrl = (app) ->
        "/mnoe/launch/#{app.uid}"

      appPromise = MnoeAppInstances.getAppInstances()
      subPromise = if MnoeOrganizations.role.atLeastAdmin() then MnoeProvisioning.getSubscriptions() else null

      $q.all({apps: appPromise, subscriptions: subPromise}).then(
        (response) ->
          vm.apps = _.each(response.apps,
            (app) ->
              app.subscription = _.find(response.subscriptions, product?.nid == app.app_nid)
              app
          )
      ).finally(-> vm.isLoading = false)

      return
  )
