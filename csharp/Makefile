app: task.o
	mono Task.exe

task.o:
	csc Task.cs

test: app
	npm run test

clean:
	rm -f task.o task.out

install:
	npm install

# configured for mac