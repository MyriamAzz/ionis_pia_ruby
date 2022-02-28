Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  mount Salesforce::API => "/"
  mount Gocardless::API => "/"
  mount Student::API => "/"

  require "sidekiq/web"
  require "sidekiq/cron/web"

  authenticate :user, lambda { |u| u.super_admin? } do
    mount Sidekiq::Web => "admin/sidekiq"
  end

  # authenticate :user, ->user { user.admin? } do
  # mount Avo::Engine, at: "avo"
  # end

  get "/politique-confidentialite", :to => "pages#politique-confidentialite"

  devise_for :users, controllers: {
                       sessions: "auths/sessions", registrations: "auths/registrations", passwords: "auths/passwords",
                     }, path: "", path_names: { sign_in: "login", sign_out: "logout", password: "forgot", registration: "register" }

  get "/email_oublie", :to => "auths/emails#new"
  post "/email_oublie", :to => "auths/emails#create"

  # root :to => "pages#portail"

  devise_scope :user do
    root :to => "pages#portail"
  end

  scope module: "user", as: "user" do
    resource :dashboard, controller: "dashboard", only: [:show] do
    end
    get "attestation_scolarite/:user_financier_subscription_id", to: "dashboard#attestation_scolarite", as: "attestation_scolarite"

    resources :factures, only: [] do
      get "facture_echeance_pdf/:user_financier_subscription_instalment_id", on: :collection, to: "factures#facture_echeance_pdf", as: "facture_echeance_pdf"
      get "facture_download/:user_financier_subscription_id", on: :collection, to: "factures#facture_pdf", as: "facture_pdf"
    end
    resource :profil, only: [:show, :update] do
      patch :update_password
    end
    resource :paiements, only: [:show] do
      get "new_mandate"
      post "validate_mandate"
      post "confirm_mandate"
      get "download_mandate/:rum", to: "paiements#download_mandate", as: "download_mandate"
      get "edit_rib"
      patch "update_rib"
      post "gocardless_payer_authorisation"
    end
    resource :support, only: [:show]
    resources :reinscriptions, only: [:show] do
      post :confirm
    end
  end

  scope module: "admin", path: "admin", as: "admin" do
    resource :dashboard, controller: "dashboard", only: [:show] do
      get :async_stats, on: :collection
      get :async_stats_1, on: :collection
      get :async_stats_2, on: :collection
      get :filter, on: :collection
      get :chart_new_registrations, on: :collection
      get :chart_registrations, on: :collection
    end
    get :dropin, to: "dashboard#dropin"

    resource :profile, only: [] do
      post :switch_centre
      post :switch_school_program
    end

    scope module: "settings", path: "settings", as: "settings" do
      resources :user_admins do
        get :json, on: :collection
        get :filter, on: :collection
      end
      resources :campus do
        get :json, on: :collection
      end
      resources :school_years do
        get :json, on: :collection
      end
      resources :payment_terms, only: [:index] do
      end

      resources :payment_plans do
      end

      resources :payment_calendars, only: [] do
        post :table, on: :collection
      end

      resources :formations do
        get "campus/:campus_id", to: "formations#campus", on: :collection, as: "campus"
        get :json, on: :collection
        get :filter, on: :collection
        get "centres/:centre_id/init_duplicate", to: "formations#init_clone", on: :collection, as: "init_clone"
        post "centres/:centre_id/clone", to: "formations#clone", on: :collection, as: "clone"
        get "centres/:centre_id/school_years/:school_year_id", to: "formations#centres_school_years", on: :collection, as: "centres_school_years"
        resources :formation_annees
      end
    end
    scope module: "manage", path: "manage", as: "manage" do
      resources :students do
        get :filter, on: :collection
        get :init_import, to: "students#init_import", on: :collection, as: "init_import"
        post :import, to: "students#import", on: :collection, as: "import"
        get :export, to: "students#export", on: :collection, as: "export"
        get :export_reinscription, to: "students#export_reinscription", on: :collection, as: "export_reinscription"
        get :table_json, to: "students#table_json", on: :collection, as: "table_json"
        get :edit_card, on: :member
        post :send_email_ids, on: :member
        patch :transfer, on: :member
        patch :follow, on: :member
        patch :dont_relaunch, on: :member
        get :change_relaunch, on: :member

        resources :user_financier_timelines
        resources :user_financier_subscriptions do
          get :preview, on: :member
          get :edit_modalite, on: :member
          get :preview_update_modalite, on: :member
          patch :update_modalite, on: :member
          get :launch_change_formation, on: :member
          get :simulate_change_formation, on: :member
          post :apply_change_formation, on: :member
          get :launch_change_statut, on: :member
          post :apply_change_statut, on: :member
          get :launch_closure, on: :member
          post :apply_closure, on: :member
          post :cancel_closure, on: :member
          get :launch_discount, on: :member
          post :simulate_discount, on: :member
          post :apply_discount, on: :member
          put :validate, to: "user_financier_subscriptions#validate", as: "validate"
          get :attestation_scolarite, on: :member

          get :edit_instalments, on: :member
          patch :update_instalments, on: :member

          get :facture_proforma_pdf, on: :member
          get :facture_pdf, on: :member

          resources :user_financier_subscription_instalments do
            get :init_retry, on: :member
            patch :canceled, on: :member
            patch :rescheduled, on: :member
            patch :force_turnover, on: :member
            patch :submit_retry, on: :member
            get :facture_pdf, on: :member
          end

          resources :user_financier_subscription_credits do
          end
        end
        resources :user_financiers, only: [:update]
        resources :user_financier_mandates, only: [] do
          get "download"
        end
      end
    end
    scope module: "accounting", path: "accounting", as: "accounting" do
      resources :invoices do
        get :filter, on: :collection
        post :process_all, on: :collection
        post :process_selected, on: :collection
        get :export_all, on: :collection
        get :export_selected, on: :collection
        get :table_json_waiting, on: :collection
        get :table_json_done, on: :collection
        get ":user_financier_subscription_id/echeancier", to: "invoices#echeancier", on: :collection, as: "echeancier"
      end
      resources :logs do
        get :filter, on: :collection

        get :table_json_logs, on: :collection
        get :export_unprocessed, on: :collection
        get :export_selected, on: :collection
        get :export_all, on: :collection
        get :export_codes_tiers, on: :collection
        get :export_ibans, on: :collection
        get :export_rf_without_mandate, on: :collection
      end
      resources :payments do
        get :filter, on: :collection
        get :widgets, on: :collection
        get :table_json, on: :collection
        get :export, on: :collection
        get :export_expired, on: :collection
        get :export_all_expired, on: :collection
        get :export_done_failed_all, on: :collection
        get :export_all, on: :collection
        get :init_import_reconciliation, on: :collection
        post :import_reconciliation, on: :collection
        get :init_export_ca, on: :collection
        get :export_ca, on: :collection
        get :export_alert_frais_scolarite, on: :collection
      end

      resources :payouts do
        get :json, on: :collection
        get :export, on: :member
      end

      resources :statistics do
        get :filter, on: :collection
        get :data, on: :collection
        get :data_students, on: :collection
      end

      resources :accounting_alerts do
        get :table_json, on: :collection
      end
    end
  end
end
