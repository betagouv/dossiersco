# frozen_string_literal: true

class ServiceAgent

  attr_reader :agent

  def initialize(agent)
    @agent = agent
  end

  def reset_mot_de_passe!
    @agent.email.downcase!
    @agent.jeton = SecureRandom.base58(26)
    @agent.save
  end

end
