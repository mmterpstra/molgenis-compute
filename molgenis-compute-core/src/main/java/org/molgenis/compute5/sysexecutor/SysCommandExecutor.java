package org.molgenis.compute5.sysexecutor;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class SysCommandExecutor
{
    private String workingDirectory = null;
    private List<EnvironmentVar> environmentVarList = null;

    private StringBuffer cmdOutput = null;
    private StringBuffer cmdError = null;
    private AsyncStreamReader cmdOutputThread = null;
    private AsyncStreamReader cmdErrorThread = null;

    public void setWorkingDirectory(String workingDirectory)
    {
        this.workingDirectory = workingDirectory;
    }

    public void setEnvironmentVar(String name, String value)
    {
        if (environmentVarList == null) environmentVarList = new ArrayList<EnvironmentVar>();
        environmentVarList.add(new EnvironmentVar(name, value));
    }

    public String getCommandOutput()
    {
        return cmdOutput.toString();
    }

    public String getCommandError()
    {
        return cmdError.toString();
    }

    public int runCommand(String commandLine) throws Exception
    {
        /* run command */
        Process process = runCommandHelper(commandLine);

        /* start output and error read threads */
        startOutputAndErrorReadThreads(process.getInputStream(), process.getErrorStream());

        /* wait for command execution to terminate */
        int exitStatus = -1;
        try
        {
            exitStatus = process.waitFor();

        } catch (Throwable ex)
        {
            throw new Exception(ex.getMessage());

        } finally
        {
            /* notify output and error read threads to stop reading */
            notifyOutputAndErrorReadThreadsToStopReading();
        }

        return exitStatus;
    }
    
    private String[] getEnvTokens()
    {
        if (environmentVarList == null)
            return null;

        String[] envTokenArray = new String[environmentVarList.size()];
        Iterator<EnvironmentVar> envVarIter = environmentVarList.iterator();
        int nEnvVarIndex = 0;
        while (envVarIter.hasNext() == true)
        {
            EnvironmentVar envVar = (EnvironmentVar) (envVarIter.next());
            String envVarToken = envVar.name + "=" + envVar.value;
            envTokenArray[nEnvVarIndex++] = envVarToken;
        }

        return envTokenArray;
    }

    private Process runCommandHelper(String commandLine) throws IOException
    {
        Process process = null;
        if (workingDirectory == null)
            process = Runtime.getRuntime().exec(commandLine, getEnvTokens());
        else
            process = Runtime.getRuntime().exec(commandLine, getEnvTokens(), new File(workingDirectory));

        return process;
    }

    private void startOutputAndErrorReadThreads(InputStream processOut, InputStream processErr)
    {
        cmdOutput = new StringBuffer();
        cmdOutputThread = new AsyncStreamReader(processOut, cmdOutput);
        cmdOutputThread.start();

        cmdError = new StringBuffer();
        cmdErrorThread = new AsyncStreamReader(processErr, cmdError);
        cmdErrorThread.start();
    }

    private void notifyOutputAndErrorReadThreadsToStopReading()
    {
		cmdOutputThread.stopReading();
        cmdErrorThread.stopReading();
    }
}
