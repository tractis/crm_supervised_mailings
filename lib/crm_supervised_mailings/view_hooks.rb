class ViewHooks < FatFreeCRM::Callback::Base
  
  ACTIONS_FOR_SHOW = <<EOS
- model_name = model.to_s
= link_to "Add to Mailing", addmails_mailing_path("Account")

EOS

  #----------------------------------------------------------------------------
  [ :account, :contact, :lead ].each do |model|

    define_method :"index_#{model}_sidebar_bottom" do |view, context|
      Haml::Engine.new(ACTIONS_FOR_SHOW).render(view, :model => context[model])
    end

  end

end
