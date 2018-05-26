import spade
import time

class FirstAgent(spade.Agent.Agent):
	'''
	class Behav(spade.Behaviour.Behaviour):
		def onStart(self):
			print "Starting behaviour..."
			self.counter = 0
		def _process(self):
			print "Counter: ", self.counter
			self.counter = self.counter + 1
			time.sleep(1)
			#delay(200)
	'''
	def _setup(self):
		print "This is the SPADE Agent Mark I, starting..."
		#behaviour = self.Behav()
		#self.addBehaviour(behaviour, None)

if __name__ == "__main__":
	a = FirstAgent("agent@127.0.0.1", "secret")
	a.start()
	#agent1.stop()