require 'Bunchball'
class BunchballHelper

  def get_client_goals(client)
    goals = {
      'hyundai' => [
        { name: 'perfectassessment', value: 100, regex: /Perfect Score/ },
        { name: 'assessment', value: 90, regex: /90%/ },
        { name: 'qa', value: 3, regex: /QA/ },
        { name: 'attendance', value: 1, regex: /Perfect Attendence/},
        { name: 'ontimefirstday', value: 1, regex: /On time the first day/},
        { name: 'graduation', value: 1, regex: /Graduation/ },
        { name: 'empathy', value: 1, regex: /Empathy/},
        { name: 'notes', value: 1, regex: /Notes/ },
        { name: 'efficiency', value: 1, regex: /Efficiency/},
        { name: 'performer', value: 1, regex: /Performer/},
        { name: 'navigator', value: 1, regex: /Skillful navigator/ }
      ]
    }
    return goals[client.downcase]
  end

  def get_goal(mission_name, goals)
    goals.each do |goal|
      return goal[:value] if mission_name.match goal[:regex]
    end
  end

  def check_missions(missions)
    bb = Bunchball.new('98086')
    errors = []
    existing = []
    missions.each_with_index do |m, i|
      if i > 0
        if bb.mission_exists?(m)
          existing.push({ name: m, exists: true })
        else
          existing.push({ name: m, exists: false })
          errors.push m
        end
      else
        existing.push({ name: "ORACLE ID PLACEHOLDER - DO NOT CHANGE" })
      end
    end
    return { missions: existing, errors: errors }
  end

end