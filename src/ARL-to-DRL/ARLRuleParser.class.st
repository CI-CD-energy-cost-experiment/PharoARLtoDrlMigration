Class {
	#name : #ARLRuleParser,
	#superclass : #Object,
	#category : #'ARL-to-DRL'
}

{ #category : #'as yet unclassified' }
ARLRuleParser >> convertARLToDRL: rule [

	| salience conditions actions drlRule |
	     1 halt. 
        salience := rule at: 'priority' ifAbsent: [''].
        conditions := rule at: 'conditions' ifAbsent: [''].
        actions := rule at: 'actions' ifAbsent: [''].

        "Convert conditions"
        conditions := conditions 
            replaceAllRegex: 'com.bl.drools.demo.Customer\(\) from \$EngineData\.this\.customer;' 
            with: 'customerObject: Customer()'.
        conditions := conditions 
            replaceAllRegex: 'evaluate \(\$EngineData\.this\.customer\.totalSpending >= 100\);' 
            with: 'customerObject: Customer(totalSpending > 100)'.

        "Convert actions"
        actions := actions 
            replaceAllRegex: '\$EngineData\.this\.customer\.discount = 5;' 
            with: 'customerObject setDiscount: 5'.

        drlRule := 'dialect "mvel"', String cr,
    		'rule', (rule at: 'name') "ifAbsent: ''", String cr,
        	'salience ', salience, String cr,
   			'when', String cr,
         '	', conditions, String cr, 
         'then', String cr,
         '	', actions, String cr,
         'end'.

      ^ drlRule
]

{ #category : #accessing }
ARLRuleParser >> main [
	
	 | arlRule filePath parsedRule drlRule |
        arlRule := 
            'rule `New customer and a big spender at birthday offer` {',
            '	property priority = 8;cr',
            '	effectiveDate = new java.util.Date(\"6/20/2024 0:00 +0200\");',
            '	expirationDate = new java.util.Date(\"6/23/2024 0:00 +0200\");',
            '	ilog.rules.business_name = \"rule one\";',
            '	ilog.rules.dt = \"\";cr',
            '	ilog.rules.package_name = \"\";',
	         '	status = \"new\";',
		      '	when {',
			   '		com.bl.drools.demo.Customer() from $EngineData.this.customer;',
				'		evaluate ( $EngineData.this.customer.totalSpending >= 100);',
				'	}',
				'	then {',
				'		$EngineData.this.customer.discount = 5;',
				'	}',
				'}'.
	
           
        filePath := 'C:\Users\boubouthiam.niang\workspace\bl\rbms\migration\odmtodroolsbis\src\main\resources\rules\rule1.drl'.
        
1 halt.
        parsedRule := self parseARLRule: arlRule.
        drlRule := self convertARLToDRL: parsedRule.
        self writeDRLStringToFile: drlRule filePath: filePath.
]

{ #category : #parsing }
ARLRuleParser >> parseARLRule: ruleText [

	| patterns rule regex matcher |
		1 halt.        

        "Regular expressions for extracting rule components"
        patterns := Dictionary new.
         
        "TODO - remember to check the imùpact of using (.+) instead of (.+?) as for java and python version"
        patterns at: 'name' put: 'rule `(.+)` \{';
                  at: 'priority' put: 'property priority = (\d+);';
                  at: 'effective_date' put: 'effectiveDate = new java\.util\.Date\("(.+)"\);';
                  at: 'expiration_date' put: 'expirationDate = new java\.util\.Date\("(.+)"\);';
                  at: 'status' put: 'status = "(.+)";';
                  at: 'conditions' put: 'when \{(.*)\}';
                  at: 'actions' put: 'then \{(.*)\}'.
        
        rule := Dictionary new.

        "regex := 'rule `(.+?)` \{' asRegex."   "problem with (.+?)"
        "regex := 'rule `(.+)` \{' asRegex."


		  "regex := 'rule `New customer and a big spender at birthday offer` \{' asRegex. "
		
		  "matcher := regex matchesIn: ruleText."
	
		
		  "rule at: 'name' put: (matcher first trim)."
		
		  1 halt.
        patterns keysAndValuesDo: [ :key :pattern |
            regex := pattern asRegex.
            matcher := regex matchesIn: ruleText.
            matcher isEmpty ifFalse: [
                rule at: key put: (matcher first trim).
					"rule at: key put: ((matcher subexpression: 1) trim)."
            ].
        ].
        
        ^ rule
]

{ #category : #writing }
ARLRuleParser >> writeDRLStringToFile: drlRuleStr filePath: filePath [
		  1 halt. 
        filePath asFileReference ensureDelete; 
			writeStreamDo: [ :stream | stream nextPutAll: drlRuleStr ].
			
        Transcript show: 'File written successfully.'; cr.
]
